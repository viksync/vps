#!/usr/bin/env bash
set -euo pipefail
# Creates the VPS user, adds them to sshu+sudo, and installs their SSH public key.
# Requires: NEW_USER env var

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/utils.sh"

if [[ $EUID -ne 0 ]]; then
  err "Run this as root"
  exit 1
fi

: "${NEW_USER:?NEW_USER not set}"

# ── User + group ──────────────────────────────────────────────
getent group sshu >/dev/null || groupadd sshu &>/dev/null
ok "Group 'sshu' ready"

if ! id "${NEW_USER}" &>/dev/null; then
  useradd -m -s /bin/bash "${NEW_USER}" &>/dev/null
  info "Set password for '${NEW_USER}':"
  passwd "${NEW_USER}"
fi

usermod -aG sshu,sudo "${NEW_USER}" &>/dev/null
ok "User '${NEW_USER}' in groups sshu + sudo"

# ── SSH public key ────────────────────────────────────────────
SSH_DIR="/home/${NEW_USER}/.ssh"
AUTH_KEYS="${SSH_DIR}/authorized_keys"

mkdir -p "$SSH_DIR"
touch "$AUTH_KEYS"
chown -R "${NEW_USER}:${NEW_USER}" "$SSH_DIR"
chmod 700 "$SSH_DIR"
chmod 600 "$AUTH_KEYS"

echo ""
echo "┌─────────────────────────────────────────────────────┐"
echo "│  Paste your SSH public key below, then press Enter  │"
echo "│  (starts with ssh-ed25519, ssh-rsa, etc.)           │"
echo "└─────────────────────────────────────────────────────┘"
read -r -p "> " PUBKEY

if [[ -z "$PUBKEY" ]]; then
  err "No key entered. Add it manually to ${AUTH_KEYS}"
elif [[ "$PUBKEY" != ssh-* ]]; then
  err "Doesn't look like an SSH public key (no 'ssh-' prefix)"
  err "Key NOT written. Add it manually to ${AUTH_KEYS}"
else
  echo "$PUBKEY" >>"$AUTH_KEYS"
  chown "${NEW_USER}:${NEW_USER}" "$AUTH_KEYS"
  chmod 600 "$AUTH_KEYS"
  ok "Public key written to ${AUTH_KEYS}"
fi
