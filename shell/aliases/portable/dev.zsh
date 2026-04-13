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


# ===============================
# PYTHON
# ===============================

python() {
  python3 "$@"
}

pip() {
  pip3 "$@"
}


# ===============================
# Docker
# ===============================

dcd() {
  docker compose down
}

dcu() {
  docker compose up
}


#------------------------
#       Other
# -----------------------

tsn() {
  npx tsc --noEmit
}
