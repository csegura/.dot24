#!/usr/bin/env bash
# backup.sh — incremental snapshot backup via rsync --link-dest
# Usage: backup.sh [-n|--dry-run] [-v|--verbose]
#
# Each run creates a timestamped snapshot on the remote; unchanged files are
# hard-linked from the previous snapshot (space-efficient full snapshots).
# Remote layout:
#   ~/usb/bak_acr/
#     backup-home/
#       2026-07-11T12:00:00/   <- snapshot
#       current -> ...         <- symlink to latest snapshot
#     backup-prj/
#       ...

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# ---------------------------------------------------------------------------
# Config — loaded from file, never hardcoded here.
# Search order: ~/.config/backup/backup.conf -> <script_dir>/backup.conf
# Copy backup.conf.example to one of those paths and edit it.
# ---------------------------------------------------------------------------
CONFIG_FILE=""
for candidate in \
    "${HOME}/.config/backup/backup.conf" \
    "${SCRIPT_DIR}/backup.conf"; do
  if [[ -f "$candidate" ]]; then
    CONFIG_FILE="$candidate"
    break
  fi
done

if [[ -z "$CONFIG_FILE" ]]; then
  echo "ERROR: No config file found. Create one of:"
  echo "  ~/.config/backup/backup.conf"
  echo "  ${SCRIPT_DIR}/backup.conf"
  echo ""
  echo "See ${SCRIPT_DIR}/backup.conf.example for reference."
  exit 6
fi

# Defaults (override any of these in backup.conf)
# Set REMOTE to empty string "" for local backup (DEST_BASE is a local path)
# Set REMOTE to "user@host" for remote backup over SSH
SSH_KEY="${HOME}/.ssh/nikita"
REMOTE=""
DEST_BASE="/srv/backups"
LOG_DIR="${HOME}/.local/share/backup-logs"
LOCK_FILE="/tmp/backup-acr.lock"
KEEP_SNAPSHOTS=30
EXCLUDES_FILE="${SCRIPT_DIR}/backup-excludes.txt"
SOURCES=()

# shellcheck source=/dev/null
source "$CONFIG_FILE"

if [[ ${#SOURCES[@]} -eq 0 ]]; then
  echo "ERROR: SOURCES array is empty in $CONFIG_FILE"
  exit 6
fi

# ---------------------------------------------------------------------------
# Flags
# ---------------------------------------------------------------------------
DRY_RUN=false
VERBOSE=false
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=true  ;;
    -v|--verbose) VERBOSE=true  ;;
    *) echo "Unknown argument: $arg"; echo "Usage: $0 [-n|--dry-run] [-v|--verbose]"; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------------
# Colors & logging
# ---------------------------------------------------------------------------
if [[ -t 1 ]]; then
  RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
  BLUE='\033[0;34m' BOLD='\033[1m' RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
LOG_FILE="${LOG_DIR}/backup-${TIMESTAMP}.log"

log() {
  local level="$1"; shift
  local color=""
  case "$level" in
    INFO)  color="$BLUE"   ;;
    OK)    color="$GREEN"  ;;
    WARN)  color="$YELLOW" ;;
    ERROR) color="$RED"    ;;
  esac
  local line="[$(date +%H:%M:%S)] [$level] $*"
  echo -e "${color}${line}${RESET}" | tee -a "$LOG_FILE"
}

# ---------------------------------------------------------------------------
# Lock file
# ---------------------------------------------------------------------------
if [[ -e "$LOCK_FILE" ]]; then
  pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "unknown")
  echo "ERROR: Another backup may be running (PID $pid). Remove $LOCK_FILE if stale." >&2
  exit 1
fi
echo $$ > "$LOCK_FILE"

cleanup() {
  local code=$?
  rm -f "$LOCK_FILE"
  [[ $code -ne 0 ]] && log ERROR "Backup failed (exit $code). Log: $LOG_FILE"
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Start
# ---------------------------------------------------------------------------
$DRY_RUN && log WARN "DRY-RUN mode — no data will be transferred"
if [[ -n "${REMOTE:-}" ]]; then
  log INFO "${BOLD}Backup started${RESET} → ${REMOTE}:${DEST_BASE}"
else
  log INFO "${BOLD}Backup started${RESET} → ${DEST_BASE} (local)"
fi
log INFO "Log: $LOG_FILE"
START_TIME=$(date +%s)

# Check connectivity / destination availability
if [[ -n "${REMOTE:-}" ]]; then
  log INFO "Checking SSH connectivity to ${REMOTE}..."
  if ! ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes "$REMOTE" "exit 0" 2>/dev/null; then
    log ERROR "Cannot reach ${REMOTE}. Aborting."
    exit 1
  fi
  log OK "SSH connection OK"
else
  if [[ ! -d "$DEST_BASE" ]]; then
    log ERROR "Local destination not found: ${DEST_BASE} (is the disk mounted?)"
    exit 1
  fi
  log OK "Local destination OK: ${DEST_BASE}"
fi

# Build rsync exclude options
EXCLUDES_OPTS=()
if [[ -f "$EXCLUDES_FILE" ]]; then
  EXCLUDES_OPTS=(--exclude-from="$EXCLUDES_FILE")
  log INFO "Excludes: $EXCLUDES_FILE"
else
  log WARN "Excludes file not found: $EXCLUDES_FILE (continuing without excludes)"
fi

# ---------------------------------------------------------------------------
# Backup loop
# ---------------------------------------------------------------------------
FAILED=()

for entry in "${SOURCES[@]}"; do
  dest_name="${entry%%:*}"
  src_path="${entry#*:}"

  echo ""
  log INFO "${BOLD}=== ${dest_name} ===${RESET}"

  if [[ ! -d "$src_path" ]]; then
    log WARN "Source not found, skipping: $src_path"
    continue
  fi

  snap_dir="${DEST_BASE}/${dest_name}/${TIMESTAMP}"
  prev_link="${DEST_BASE}/${dest_name}/current"

  if [[ -n "${REMOTE:-}" ]]; then
    ssh -i "$SSH_KEY" "$REMOTE" "mkdir -p '${DEST_BASE}/${dest_name}'"
    log INFO "Source:   $src_path"
    log INFO "Snapshot: ${REMOTE}:${snap_dir}"
  else
    mkdir -p "${DEST_BASE}/${dest_name}"
    log INFO "Source:   $src_path"
    log INFO "Snapshot: ${snap_dir}"
  fi

  rsync_opts=(
    -aHAX
    --info=progress2
    --stats
    "${EXCLUDES_OPTS[@]}"
    --link-dest="${prev_link}/"
  )
  [[ -n "${REMOTE:-}" ]] && rsync_opts+=(-e "ssh -i $SSH_KEY")
  $DRY_RUN && rsync_opts+=(--dry-run)
  $VERBOSE && rsync_opts+=(-v)

  # Build destination argument (remote or local)
  if [[ -n "${REMOTE:-}" ]]; then
    rsync_dest="${REMOTE}:${snap_dir}/"
  else
    rsync_dest="${snap_dir}/"
  fi

  src_ts=$(date +%s)
  if rsync "${rsync_opts[@]}" "${src_path}/" "${rsync_dest}" 2>&1 | tee -a "$LOG_FILE"; then
    elapsed=$(( $(date +%s) - src_ts ))
    if ! $DRY_RUN; then
      # Update 'current' symlink atomically
      if [[ -n "${REMOTE:-}" ]]; then
        ssh -i "$SSH_KEY" "$REMOTE" "ln -sfn '${snap_dir}' '${prev_link}'"
        # Prune oldest snapshots beyond KEEP_SNAPSHOTS
        ssh -i "$SSH_KEY" "$REMOTE" "
          cd '${DEST_BASE}/${dest_name}' &&
          ls -1d [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]* 2>/dev/null \
            | sort | head -n -${KEEP_SNAPSHOTS} | xargs -r rm -rf --
        "
      else
        ln -sfn "${snap_dir}" "${prev_link}"
        # Prune oldest snapshots beyond KEEP_SNAPSHOTS
        (
          cd "${DEST_BASE}/${dest_name}" &&
          ls -1d [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]* 2>/dev/null \
            | sort | head -n -${KEEP_SNAPSHOTS} | xargs -r rm -rf --
        )
      fi
    fi
    log OK "${dest_name} done in ${elapsed}s"
  else
    log ERROR "${dest_name} rsync failed"
    FAILED+=("$dest_name")
  fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
DURATION=$(( $(date +%s) - START_TIME ))
MINS=$(( DURATION / 60 ))
SECS=$(( DURATION % 60 ))

if [[ ${#FAILED[@]} -gt 0 ]]; then
  log ERROR "Completed with errors in ${MINS}m ${SECS}s — failed: ${FAILED[*]}"
  log ERROR "Log: $LOG_FILE"
  exit 1
else
  log OK "${BOLD}All backups completed in ${MINS}m ${SECS}s${RESET}"
  log OK "Log: $LOG_FILE"
fi
