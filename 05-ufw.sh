#!/usr/bin/env bash
set -euo pipefail
# Configures UFW: deny all, allow 80/443, allow SSH only over Tailscale.
# Requires: SSH_PORT env var

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/utils.sh"

if [[ $EUID -ne 0 ]]; then
  err "Run this as root"
  exit 1
fi

: "${SSH_PORT:?SSH_PORT not set}"

spin "Configuring firewall" bash -c "
  ufw --force reset
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw allow in on tailscale0 to any port '${SSH_PORT}' proto tcp
  ufw deny '${SSH_PORT}'/tcp
  ufw --force enable
"
