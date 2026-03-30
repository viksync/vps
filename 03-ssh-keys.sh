#!/usr/bin/env bash
set -euo pipefail
# Copies GitHub SSH keys + config from root to new user and fixes .ssh permissions.
# Requires: NEW_USER env var

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/utils.sh"

if [[ $EUID -ne 0 ]]; then
  err "Run this as root"
  exit 1
fi

: "${NEW_USER:?NEW_USER not set}"

SSH_SRC="/root/.ssh"
SSH_DST="/home/${NEW_USER}/.ssh"

mkdir -p "$SSH_DST"

# ── Copy GitHub deploy key ────────────────────────────────
for f in vps_github vps_github.pub; do
  if [[ -f "${SSH_SRC}/${f}" ]]; then
    cp "${SSH_SRC}/${f}" "${SSH_DST}/${f}"
    ok "Copied ${f}"
  else
    info "Skipping ${f} (not found in ${SSH_SRC})"
  fi
done

# ── Copy SSH client config ────────────────────────────────
if [[ -f "${SSH_SRC}/config" ]]; then
  cp "${SSH_SRC}/config" "${SSH_DST}/config"
  ok "Copied config"
else
  info "Skipping config (not found in ${SSH_SRC})"
fi

# ── Fix all .ssh permissions ──────────────────────────────
chown -R "${NEW_USER}:${NEW_USER}" "$SSH_DST"
chmod 700 "$SSH_DST"
chmod 600 "${SSH_DST}"/* 2>/dev/null || true
# Public keys should be 644
[[ -f "${SSH_DST}/vps_github.pub" ]] && chmod 644 "${SSH_DST}/vps_github.pub"
[[ -f "${SSH_DST}/authorized_keys" ]] && chmod 600 "${SSH_DST}/authorized_keys"

ok "Permissions fixed on ${SSH_DST}"
