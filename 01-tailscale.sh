#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/utils.sh"

if [[ $EUID -ne 0 ]]; then
  err "Run this as root"
  exit 1
fi

spin "Installing Tailscale" bash -c "curl -fsSL https://tailscale.com/install.sh | sh"

info "Starting Tailscale (authenticate in browser)"
tailscale up --advertise-tags=tag:vps

info "Detecting Tailscale IP"
TS_IP=$(tailscale ip -4 2>/dev/null | head -n1)

if [[ -z "$TS_IP" ]]; then
  err "Failed to get Tailscale IP — did you authenticate?"
  exit 1
fi

ok "Tailscale IP: $TS_IP"
