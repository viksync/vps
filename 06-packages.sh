#!/usr/bin/env bash
set -euo pipefail
# Installs all packages for VPS_USER.
# Requires: VPS_USER env var, must run as root.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/utils.sh"

: "${VPS_USER:?VPS_USER not set}"

_local="/home/$VPS_USER/.local"
_bin="$_local/bin"
mkdir -p "$_bin" "$_local/share"
chown -R "$VPS_USER:$VPS_USER" "$_local"

# ----------------------------------------
# 1. apt packages
# ----------------------------------------
spin "Installing apt packages" \
  apt-get install -y -qq git jq pipx

# ----------------------------------------
# 2. GitHub CLI (official apt repo)
# ----------------------------------------
if command -v gh &>/dev/null; then
  ok "gh already installed"
else
  spin "Installing gh" bash -c '
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list
    apt-get update -qq && apt-get install -y -qq gh
  '
fi

# ----------------------------------------
# 3. Node.js LTS (NodeSource apt repo)
# ----------------------------------------
if command -v node &>/dev/null; then
  ok "node already installed"
else
  spin "Installing Node.js LTS" bash -c '
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt-get install -y -qq nodejs
  '
fi

# ----------------------------------------
# 4. GitHub release binaries → ~/.local/bin
# ----------------------------------------
_install() {
  local binary="$3"
  if [[ -x "$_bin/$binary" ]]; then
    ok "$binary already installed"
  else
    spin "Installing $binary" gh_install "$@"
  fi
}

_install sharkdp/bat              'bat-v.*-x86_64-unknown-linux-musl\.tar\.gz'      bat
_install eza-community/eza        'eza_x86_64-unknown-linux-musl\.tar\.gz'          eza
_install sharkdp/fd               'fd-v.*-x86_64-unknown-linux-musl\.tar\.gz'       fd
_install junegunn/fzf             'fzf-.*-linux_amd64\.tar\.gz'                     fzf
_install simeji/jid               'jid_linux_amd64\.zip$'                           jid
_install jesseduffield/lazydocker 'lazydocker_.*_Linux_x86_64\.tar\.gz'             lazydocker
_install jesseduffield/lazygit    'lazygit_.*_linux_x86_64\.tar\.gz'                lazygit
_install BurntSushi/ripgrep       'ripgrep-.*-x86_64-unknown-linux-musl\.tar\.gz'   rg
_install sxyazi/yazi              'yazi-x86_64-unknown-linux-musl\.zip$'            yazi
_install sxyazi/yazi              'yazi-x86_64-unknown-linux-musl\.zip$'            ya
_install zellij-org/zellij        'zellij-x86_64-unknown-linux-musl\.tar\.gz'       zellij
_install ajeetdsouza/zoxide       'zoxide-.*-x86_64-unknown-linux-musl\.tar\.gz'    zoxide

# ----------------------------------------
# 5. Neovim (full archive — runtime files needed)
# ----------------------------------------
if [[ -x "$_bin/nvim" ]]; then
  ok "nvim already installed"
else
  spin "Installing neovim" bash -c "
    version=\$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.tag_name')
    curl -fsSL \"https://github.com/neovim/neovim/releases/download/\${version}/nvim-linux-x86_64.tar.gz\" \
      -o /tmp/nvim.tar.gz
    tar -xf /tmp/nvim.tar.gz -C $_local/share/
    ln -sf $_local/share/nvim-linux-x86_64/bin/nvim $_bin/nvim
    chown -R $VPS_USER:$VPS_USER $_local/share/nvim-linux-x86_64
    rm /tmp/nvim.tar.gz
  "
fi

# ----------------------------------------
# 6. Install scripts (run as VPS_USER)
# ----------------------------------------
if as_user bash -c 'command -v rtk &>/dev/null'; then
  ok "rtk already installed"
else
  spin "Installing rtk" \
    as_user bash -c 'curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh'
fi

# ----------------------------------------
# 7. httpie (via pipx)
# ----------------------------------------
if as_user bash -c 'command -v http &>/dev/null'; then
  ok "httpie already installed"
else
  spin "Installing httpie" as_user pipx install httpie
fi

# ----------------------------------------
# 8. Bun
# ----------------------------------------
if [[ -x "$_bin/bun" ]]; then
  ok "bun already installed"
else
  spin "Installing bun" \
    as_user bash -c 'curl -fsSL https://bun.sh/install | bash'
  ln -sf "/home/$VPS_USER/.bun/bin/bun" "$_bin/bun"
  chown -h "$VPS_USER:$VPS_USER" "$_bin/bun"
fi

# ----------------------------------------
# 9. Claude Code CLI
# ----------------------------------------
if [[ -x "$_bin/claude" ]]; then
  ok "claude already installed"
else
  spin "Installing claude" \
    as_user bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  # Symlink into ~/.local/bin if the installer didn't place it there
  if [[ ! -x "$_bin/claude" ]]; then
    _claude_bin=$(as_user bash -c 'command -v claude 2>/dev/null || true')
    [[ -n "$_claude_bin" ]] && ln -sf "$_claude_bin" "$_bin/claude" && \
      chown -h "$VPS_USER:$VPS_USER" "$_bin/claude"
  fi
fi

# ----------------------------------------
# 10. Codex CLI
# ----------------------------------------
if [[ -x "$_bin/codex" ]]; then
  ok "codex already installed"
else
  spin "Installing codex" \
    as_user bash -c 'curl -fsSL https://chatgpt.com/codex/install.sh | sh'
fi

# ----------------------------------------
# 11. pnpm
# ----------------------------------------
if as_user bash -c 'command -v pnpm &>/dev/null'; then
  ok "pnpm already installed"
else
  spin "Installing pnpm" \
    as_user bash -c 'curl -fsSL https://get.pnpm.io/install.sh | sh -'
fi
