#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLS_DIR="$REPO_DIR/tools"

source "$REPO_DIR/utils.sh"

# ----------------------------------------
# 1. Directories
# ----------------------------------------
mkdir -p \
  "$HOME/.config/yazi" \
  "$HOME/.config/zellij"
ok "Directories ready"

# ----------------------------------------
# 2. Symlinks
# ----------------------------------------
symlink "$TOOLS_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
symlink "$TOOLS_DIR/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
symlink "$TOOLS_DIR/yazi/package.toml" "$HOME/.config/yazi/package.toml"
symlink "$TOOLS_DIR/zellij.kdl" "$HOME/.config/zellij/config.kdl"
ok "Symlinks created"

# ----------------------------------------
# 3. Yazi packages (flavors / plugins)
# ----------------------------------------
ya pkg install
ok "Yazi packages installed"
