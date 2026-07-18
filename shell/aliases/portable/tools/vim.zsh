# ===============================
# VIM
# ===============================

v() {
  nvim "$@"
}

vc() {
  nvim $HOME/.config/nvim/ "$@"
}

vk() {
  nvim $HOME/.config/nvim/lua/config/keymaps.lua "$@"
}

