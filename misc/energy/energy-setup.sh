#!/usr/bin/env bash
# energy-setup.sh — apply energy-saving measures on a headless Linux server
# Tested on: Apple Mac Mini 7,1 (Haswell i5), Debian 13
# Usage: sudo ./energy-setup.sh
set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' RESET='\033[0m'
info()  { echo -e "${GREEN}[+]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $*"; }
error() { echo -e "${RED}[✗]${RESET} $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || error "Run as root: sudo $0"

# 1. Install TLP
info "Installing TLP..."
apt-get install -y tlp tlp-rdw > /dev/null 2>&1
info "TLP $(tlp --version) installed"

# 2. Deploy TLP config
info "Deploying TLP config..."
cp "${SCRIPT_DIR}/tlp-server.conf" /etc/tlp.d/99-server.conf
info "Config written to /etc/tlp.d/99-server.conf"

# 3. Disable Bluetooth (unused on headless server)
if systemctl is-enabled bluetooth &>/dev/null; then
  systemctl disable --now bluetooth
  info "Bluetooth disabled"
else
  info "Bluetooth already disabled"
fi

# 4. Apply TLP now
tlp start
info "TLP started"

echo ""
info "Done. Run 'sudo tlp-stat -s' to verify."
warn "Edit /etc/tlp.d/99-server.conf to tune disk spindown timeouts for your hardware."
