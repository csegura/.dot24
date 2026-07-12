#!/usr/bin/env bash
# server-backup.sh — local incremental backup of system paths to a mounted disk
# Usage: server-backup.sh <command> [options]
#
# Commands:
#   run             Perform backup now (all sources)
#   enable          Install and enable systemd timer (requires sudo)
#   disable         Disable systemd timer (requires sudo)
#   status          Show timer state, last snapshots and disk usage
#   list            List all snapshots per source
#
# Options for run:
#   -n, --dry-run   Preview rsync without transferring
#   -v, --verbose   Verbose rsync output
#   -h, --help      Show this help
#
# Config: ~/.config/backup/server-backup.conf
#         (copy from ~/.dotfiles/misc/backup/server-backup.conf.example)

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
HOST="$(hostname -s)"
SERVICE_NAME="${HOST}-backup"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
TIMER_FILE="/etc/systemd/system/${SERVICE_NAME}.timer"

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
CONFIG_FILE=""
for candidate in \
    "${HOME}/.config/backup/server-backup.conf" \
    "${SCRIPT_DIR}/server-backup.conf"; do
  if [[ -f "$candidate" ]]; then
    CONFIG_FILE="$candidate"
    break
  fi
done

if [[ -z "$CONFIG_FILE" ]]; then
  echo "ERROR: No config file found." >&2
  echo "  Copy ${SCRIPT_DIR}/server-backup.conf.example" >&2
  echo "  to   ~/.config/backup/server-backup.conf and edit it." >&2
  exit 1
fi

# Defaults (overridden by config)
DEST_BASE="/srv/backups"
KEEP_SNAPSHOTS=30
SCHEDULE="03:00"
EXCLUDES_FILE="${SCRIPT_DIR}/backup-excludes.txt"
SOURCES=()

# shellcheck source=/dev/null
source "$CONFIG_FILE"

if [[ ${#SOURCES[@]} -eq 0 ]]; then
  echo "ERROR: SOURCES array is empty in ${CONFIG_FILE}" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m✔  %s\033[0m\n' "$*"; }
info()  { printf '\033[1;36mℹ  %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m⚠  %s\033[0m\n' "$*"; }
err()   { printf '\033[1;31m✖  %s\033[0m\n' "$*" >&2; }
sep()   { printf '\033[2m%s\033[0m\n' "$(printf '─%.0s' {1..60})"; }

# ---------------------------------------------------------------------------
# run command
# ---------------------------------------------------------------------------
cmd_run() {
  local dry_run=false verbose=false
  for arg in "$@"; do
    case "$arg" in
      -n|--dry-run) dry_run=true ;;
      -v|--verbose) verbose=true ;;
    esac
  done

  # Lock file — prevent concurrent runs (global so trap can reach it)
  LOCK_FILE="/tmp/${SERVICE_NAME}.lock"
  if [[ -e "$LOCK_FILE" ]]; then
    err "Backup already running (lock: $LOCK_FILE). Abort."
    exit 1
  fi
  trap 'rm -f "$LOCK_FILE"' EXIT
  touch "$LOCK_FILE"

  local timestamp
  timestamp="$(date +%Y-%m-%dT%H:%M:%S)"
  local errors=0

  bold "═══ Server Backup — ${HOST} — ${timestamp}"
  $dry_run && warn "DRY RUN — no data will be written."
  sep

  for entry in "${SOURCES[@]}"; do
    local name="${entry%%:*}"
    local src_path="${entry#*:}"
    local dest_dir="${DEST_BASE}/${HOST}-${name}"
    local snap_dir="${dest_dir}/${timestamp}"
    local current_link="${dest_dir}/current"

    printf '\033[1;36m%-20s\033[0m %s → %s\n' "${name}" "${src_path}" "${dest_dir}"

    # Check source exists
    if [[ ! -e "$src_path" ]]; then
      warn "  Source not found, skipping: ${src_path}"
      continue
    fi

    # Check destination is mounted/writable
    if [[ ! -d "$DEST_BASE" ]]; then
      err "  Destination not available: ${DEST_BASE}"
      ((errors++)) || true
      continue
    fi

    local rsync_args=(
      --archive
      --hard-links
      --acls
      --xattrs
      --delete
      --delete-excluded
      --numeric-ids
      --human-readable
      --stats
    )
    $verbose && rsync_args+=(--verbose)
    [[ -f "$EXCLUDES_FILE" ]] && rsync_args+=(--exclude-from="$EXCLUDES_FILE")

    # Link-dest from previous snapshot if it exists
    if [[ -d "$current_link" ]]; then
      rsync_args+=(--link-dest="$current_link")
    fi

    # Ensure trailing slash on source (rsync semantics: copy contents)
    local src="${src_path%/}/"

    if $dry_run; then
      rsync_args+=(--dry-run)
      info "  [dry-run] rsync ${src} → ${snap_dir}/"
      rsync "${rsync_args[@]}" "$src" "${snap_dir}/" 2>&1 | tail -5 | sed 's/^/    /' || true
    else
      mkdir -p "$snap_dir"
      local t_start=$SECONDS rc=0
      rsync "${rsync_args[@]}" "$src" "${snap_dir}/" 2>&1 | tail -8 | sed 's/^/    /' || rc=$?
      # rc 23/24: partial transfer (unreadable files) — treat as warning
      if [[ $rc -eq 0 || $rc -eq 23 || $rc -eq 24 ]]; then
        [[ $rc -ne 0 ]] && warn "  Some files skipped (rc=${rc}, likely permission-denied)"
        # Update current symlink
        ln -sfn "${snap_dir}" "${current_link}"
        printf '  \033[1;32m✔\033[0m  Done in %ds\n' $(( SECONDS - t_start ))

        # Prune old snapshots
        local count
        count=$(find "$dest_dir" -mindepth 1 -maxdepth 1 -type d | wc -l)
        if (( count > KEEP_SNAPSHOTS )); then
          local excess=$(( count - KEEP_SNAPSHOTS ))
          info "  Pruning ${excess} old snapshot(s)…"
          find "$dest_dir" -mindepth 1 -maxdepth 1 -type d \
            | sort | head -"$excess" | xargs rm -rf
        fi
      else
        err "  rsync failed for ${name} (rc=${rc})"
        rm -rf "$snap_dir"
        ((errors++)) || true
      fi
    fi
    echo
  done

  if (( errors > 0 )); then
    err "${errors} source(s) failed."
    exit 1
  else
    $dry_run || ok "All sources backed up."
  fi
}

# ---------------------------------------------------------------------------
# enable command — write systemd unit files and activate timer
# ---------------------------------------------------------------------------
cmd_enable() {
  local script_path
  script_path="$(realpath "$0")"
  local run_user="${SUDO_USER:-${USER}}"
  local run_home
  run_home="$(getent passwd "$run_user" | cut -d: -f6)"

  bold "Installing systemd units for ${HOST}…"

  cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Server backup (${HOST})
After=local-fs.target
RequiresMountsFor=${DEST_BASE}

[Service]
Type=oneshot
ExecStart=${script_path} run
User=${run_user}
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${SERVICE_NAME}
EOF

  cat > "$TIMER_FILE" <<EOF
[Unit]
Description=Daily server backup (${HOST}) at ${SCHEDULE}

[Timer]
OnCalendar=*-*-* ${SCHEDULE}:00
Persistent=true
RandomizedDelaySec=5min

[Install]
WantedBy=timers.target
EOF

  systemctl daemon-reload
  systemctl enable --now "${SERVICE_NAME}.timer"
  ok "Timer enabled: ${SERVICE_NAME}.timer"
  systemctl status "${SERVICE_NAME}.timer" --no-pager -l | head -12
}

# ---------------------------------------------------------------------------
# disable command
# ---------------------------------------------------------------------------
cmd_disable() {
  bold "Disabling ${SERVICE_NAME}.timer…"
  if systemctl is-active --quiet "${SERVICE_NAME}.timer" 2>/dev/null; then
    systemctl disable --now "${SERVICE_NAME}.timer"
    ok "Timer disabled."
  else
    info "Timer was not active."
  fi
  # Leave unit files in place so re-enable is easy
}

# ---------------------------------------------------------------------------
# status command
# ---------------------------------------------------------------------------
cmd_status() {
  bold "═══ Backup Status — ${HOST}"
  sep

  # Systemd timer state
  bold "Timer"
  if systemctl is-enabled --quiet "${SERVICE_NAME}.timer" 2>/dev/null; then
    systemctl status "${SERVICE_NAME}.timer" --no-pager -l 2>/dev/null | head -10 | sed 's/^/  /'
  else
    info "  Timer not installed (run: sudo server-backup.sh enable)"
  fi
  echo

  # Last snapshot per source
  bold "Last Snapshots"
  sep
  for entry in "${SOURCES[@]}"; do
    local name="${entry%%:*}"
    local dest_dir="${DEST_BASE}/${HOST}-${name}"
    local current_link="${dest_dir}/current"
    if [[ -L "$current_link" ]]; then
      local last
      last=$(readlink "$current_link" | xargs basename)
      local size
      size=$(du -sh "${current_link}" 2>/dev/null | cut -f1 || echo "?")
      printf '  \033[1;36m%-20s\033[0m %s  (%s)\n' "${HOST}-${name}" "$last" "$size"
    else
      printf '  \033[2m%-20s\033[0m  no snapshot yet\n' "${HOST}-${name}"
    fi
  done
  echo

  # Disk usage
  bold "Disk Usage — ${DEST_BASE}"
  sep
  df -h "$DEST_BASE" | awk 'NR==1{print "  "$0} NR==2{print "  "$0}'
  echo
}

# ---------------------------------------------------------------------------
# list command
# ---------------------------------------------------------------------------
cmd_list() {
  bold "═══ Snapshots — ${HOST}"
  sep
  for entry in "${SOURCES[@]}"; do
    local name="${entry%%:*}"
    local dest_dir="${DEST_BASE}/${HOST}-${name}"
    local current_link="${dest_dir}/current"
    local current_target=""
    [[ -L "$current_link" ]] && current_target=$(readlink "$current_link")

    bold "  ${HOST}-${name}"
    if [[ -d "$dest_dir" ]]; then
      find "$dest_dir" -mindepth 1 -maxdepth 1 -type d | sort -r | while read -r snap; do
        local label=""
        [[ "$snap" == "$current_target" ]] && label=" \033[1;32m← current\033[0m"
        local size
        size=$(du -sh "$snap" 2>/dev/null | cut -f1 || echo "?")
        printf '    %-26s  %s%b\n' "$(basename "$snap")" "$size" "$label"
      done
    else
      printf '    \033[2mno snapshots yet\033[0m\n'
    fi
    echo
  done
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
cmd="${1:-help}"
shift || true

case "$cmd" in
  run)     cmd_run "$@" ;;
  enable)  cmd_enable ;;
  disable) cmd_disable ;;
  status)  cmd_status ;;
  list)    cmd_list ;;
  -h|--help|help)
    sed -n '2,18p' "$0" | sed 's/^# \?//'
    ;;
  *)
    err "Unknown command: $cmd"
    echo "  Usage: $(basename "$0") run|enable|disable|status|list"
    exit 1
    ;;
esac
