#!/usr/bin/env bash
# nfs_share.sh — manage NFS exports for any directory
# Usage:
#   nfs_share.sh add <abs_path>    add a share (interactive if no path given)
#   nfs_share.sh remove <abs_path> remove a share
#   nfs_share.sh list              list current exports
set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
EXPORTS_FILE="/etc/exports"
NFS_OPTS="*(rw,all_squash,insecure,async,no_subtree_check,anonuid=$(id -u),anongid=$(id -g))"
OWNER="$(whoami)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' RESET='\033[0m'
info()  { echo -e "${GREEN}[+]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $*"; }
error() { echo -e "${RED}[✗]${RESET} $*" >&2; exit 1; }

require_root() {
  [[ $EUID -eq 0 ]] || error "This command must be run as root (use sudo)."
}

reload_exports() {
  info "Reloading NFS exports..."
  exportfs -ra
  echo ""
  exportfs -v
}

cmd_list() {
  echo "Current NFS exports:"
  exportfs -v 2>/dev/null || cat "$EXPORTS_FILE"
}

cmd_add() {
  require_root
  local path="${1:-}"

  # Interactive prompt if no path provided
  if [[ -z "$path" ]]; then
    read -rp "Enter absolute directory path to export: " path
  fi

  # Validate — must be absolute, no traversal
  [[ -z "$path" ]]       && error "Path cannot be empty."
  [[ "$path" != /* ]]    && error "Path must be absolute (e.g. /srv/backups or /mnt/data)."
  [[ "$path" == *..* ]] && error "Path traversal (..) is not allowed."

  local share="$path"

  # Create directory if needed
  if [[ ! -d "$share" ]]; then
    info "Creating directory: $share"
    mkdir -p "$share"
  else
    info "Directory already exists: $share"
  fi

  # Set ownership and permissions
  chown -R "${OWNER}:${OWNER}" "$share"
  find "$share" -type d -exec chmod 755 {} \;
  find "$share" -type f -exec chmod 644 {} \;
  info "Permissions set (owner: ${OWNER})"

  # Check for duplicate export
  local export_line="${share} ${NFS_OPTS}"
  if grep -qF "$share" "$EXPORTS_FILE" 2>/dev/null; then
    warn "Share already in ${EXPORTS_FILE}: $share"
    warn "Current entry:"
    grep -F "$share" "$EXPORTS_FILE" | sed 's/^/  /'
    read -rp "Replace existing entry? [y/N] " confirm
    [[ "${confirm,,}" == "y" ]] || { info "Aborted."; exit 0; }
    # Remove old entry
    sed -i "\|^${share}[[:space:]]|d" "$EXPORTS_FILE"
  fi

  echo "${export_line}" >> "$EXPORTS_FILE"
  info "Added to ${EXPORTS_FILE}: ${export_line}"

  reload_exports
}

cmd_remove() {
  require_root
  local path="${1:-}"

  if [[ -z "$path" ]]; then
    echo "Current exports:"
    grep -v '^\s*#' "$EXPORTS_FILE" | grep -v '^\s*$' | nl -ba || true
    read -rp "Enter directory path to remove (under ${MNT_BASE}/): " path
  fi

  [[ "$path" == *..* ]] && error "Path traversal (..) is not allowed."

  # Accept both relative (share) and absolute paths
  local share
  if [[ "$path" == /* ]]; then
    share="$path"
  else
    share="${MNT_BASE}/${path}"
  fi

  if ! grep -qF "$share" "$EXPORTS_FILE" 2>/dev/null; then
    error "Share not found in ${EXPORTS_FILE}: $share"
  fi

  info "Removing from ${EXPORTS_FILE}: $share"
  sed -i "\|^${share}[[:space:]]|d" "$EXPORTS_FILE"

  reload_exports
  warn "Note: directory ${share} was NOT deleted. Remove manually if no longer needed."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
CMD="${1:-list}"
shift || true

case "$CMD" in
  add)    cmd_add    "${1:-}" ;;
  remove) cmd_remove "${1:-}" ;;
  list)   cmd_list ;;
  *)
    echo "Usage: $(basename "$0") <add|remove|list> [path]"
    echo ""
    echo "  add <path>     Export any absolute directory path via NFS"
    echo "  remove <path>  Remove an NFS export"
    echo "  list           Show current exports"
    exit 2
    ;;
esac
