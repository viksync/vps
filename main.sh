#!/usr/bin/env bash
set -euo pipefail

# Must run as root: needed for apt, sshd, ufw, and `sudo -u` for user-level installs.
if [[ $EUID -ne 0 ]]; then
  echo "Run as root" >&2
  exit 1
fi

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$REPO_DIR/utils.sh"

# ── Config from arguments ─────────────────────
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <port> <username>" >&2
  exit 1
fi

SSH_PORT="$1"
VPS_USER="$2"

if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || ((SSH_PORT < 1024 || SSH_PORT > 65535)); then
  echo "Invalid port: must be a number between 1024 and 65535" >&2
  exit 1
fi

if [[ -z "$VPS_USER" ]]; then
  echo "Username cannot be empty" >&2
  exit 1
fi
echo ""

export VPS_USER SSH_PORT
export NEW_USER="$VPS_USER"

# ----------------------------------------
# 00. Apt update, upgrade, and install
# ----------------------------------------
spin "Updating apt" apt-get update -y -qq
spin "Upgrading packages" apt-get upgrade -y -qq
spin "Installing apt packages" apt-get install -y -qq curl ufw build-essential unzip zsh

# ----------------------------------------
# 01. Tailscale
# ----------------------------------------
bash "$REPO_DIR/01-tailscale.sh"

TS_IP=$(tailscale ip -4 2>/dev/null | head -n1)
export TS_IP

# ----------------------------------------
# 02. User
# ----------------------------------------
bash "$REPO_DIR/02-user.sh"

# If the repo isn't readable by VPS_USER (e.g. cloned under /root/), relocate it
# to their home dir so subsequent as_user calls can access it.
if ! sudo -u "$VPS_USER" test -r "$REPO_DIR/utils.sh" 2>/dev/null; then
  NEW_REPO_DIR="/home/$VPS_USER/vps"
  info "Repo not readable by $VPS_USER — copying to $NEW_REPO_DIR"
  cp -rL "$REPO_DIR" "$NEW_REPO_DIR"
  chown -R "$VPS_USER:$VPS_USER" "$NEW_REPO_DIR"
  chmod -R u+rX "$NEW_REPO_DIR"
  REPO_DIR="$NEW_REPO_DIR"
fi

# ----------------------------------------
# 03. SSH keys + permissions
# ----------------------------------------
bash "$REPO_DIR/03-ssh-keys.sh"

# ----------------------------------------
# 04. SSH hardening
# ----------------------------------------
bash "$REPO_DIR/04-sshd.sh"

# ----------------------------------------
# 05. UFW
# ----------------------------------------
bash "$REPO_DIR/05-ufw.sh"

# ── Verify SSH before continuing ──────────────
echo ""
info "Effective SSH config:"
sshd -T 2>/dev/null | grep -E 'listenaddress|port|allowgroups|authenticationmethods|tcpforwarding'

echo ""
info "UFW status:"
ufw status verbose

echo ""
echo "┌─────────────────────────────────────────────────────┐"
echo "│  BEFORE continuing, verify you can SSH in:          │"
echo "│                                                      │"
printf "│  ssh -p %s %s@%s\n" "${SSH_PORT}" "${VPS_USER}" "${TS_IP}"
echo "│                                                      │"
echo "│  Press Enter here once confirmed, Ctrl-C to abort.  │"
echo "└─────────────────────────────────────────────────────┘"
read -r _

# ----------------------------------------
# 06. Packages
# ----------------------------------------
bash "$REPO_DIR/06-packages.sh"

# ----------------------------------------
# 07. Docker
# ----------------------------------------
bash "$REPO_DIR/07-docker.sh"

# ----------------------------------------
# 08. Shell config
# ----------------------------------------
spin "Setting up shell config" as_user bash "$REPO_DIR/08-shell.sh"

# ----------------------------------------
# 09. Tools config
# ----------------------------------------
spin "Setting up tools config" as_user bash "$REPO_DIR/09-tools.sh"

# ----------------------------------------
# 10. Neovim config
# ----------------------------------------
spin "Setting up Neovim config" as_user bash "$REPO_DIR/10-nvim.sh"

# ----------------------------------------
# 11. Set zsh as default shell for $VPS_USER
# ----------------------------------------
ZSH_PATH="$(as_user which zsh 2>/dev/null || true)"
if [[ -z "$ZSH_PATH" ]]; then
  err "zsh not found in PATH — skipping chsh"
else
  if ! grep -qxF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" >>/etc/shells
  fi
  spin "Setting zsh as default shell" chsh -s "$ZSH_PATH" "$VPS_USER"
fi

echo ""
ok "Bootstrap complete — SSH in as $VPS_USER to finish."
