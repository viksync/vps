#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/utils.sh"

mkdir -p "$HOME/.config"

if [[ -d "$HOME/.config/nvim" ]]; then
  ok "Neovim config already cloned"
else
  spin "Cloning Neovim config" git -C "$HOME/.config" clone git@github.com:viksync/nvim.git
fi

spin "Syncing Neovim plugins" nvim --headless "+Lazy! sync" +qa
