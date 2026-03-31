#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SHELL_DIR="$REPO_DIR/shell"

source "$REPO_DIR/utils.sh"

# ----------------------------------------
# 1. Directories
# ----------------------------------------
mkdir -p \
  "$HOME/.config/p10k" \
  "$HOME/.config/shell/aliases" \
  "$HOME/.config/shell/functions" \
  "$HOME/.cache/zsh" \
  "$HOME/.local/bin" \
  "$HOME/.local/share"
ok "Directories ready"

# ----------------------------------------
# 2. Symlinks
# ----------------------------------------
symlink "$SHELL_DIR/zprofile"        "$HOME/.zprofile"
symlink "$SHELL_DIR/zshenv"          "$HOME/.zshenv"
symlink "$SHELL_DIR/zshrc"           "$HOME/.zshrc"
symlink "$SHELL_DIR/zshrc.base"      "$HOME/.config/shell/zshrc.base"
symlink "$SHELL_DIR/p10k.zsh"        "$HOME/.config/p10k/p10k.zsh"
symlink "$SHELL_DIR/aliases.zsh"     "$HOME/.config/shell/aliases.zsh"
symlink "$SHELL_DIR/aliases.base.zsh" "$HOME/.config/shell/aliases.base.zsh"

symlink "$SHELL_DIR/aliases/portable" "$HOME/.config/shell/aliases/portable"

ok "Symlinks created"

# ----------------------------------------
# 3. Zinit
# ----------------------------------------
ZINIT_DIR="$HOME/.local/share/zinit/zinit.git"
if [[ -d "$ZINIT_DIR" ]]; then
  ok "zinit already installed"
else
  spin "Installing zinit" bash -c \
    "$(curl --fail --show-error --silent --location \
      https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi

echo ""
ok "Done. Open a new shell or: source ~/.zshrc"
