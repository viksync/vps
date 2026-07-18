# ===============================
# SYSTEM & SHELL
# ===============================

soz() {
  source $HOME/.zshrc "$@"
}

soa() {
  source $HOME/.config/shell/aliases.zsh
}

# e → edit + command
ea() {
  nvim $HOME/.config/shell/aliases/ && source $HOME/.config/shell/aliases.zsh
}

ez() {
  nvim $HOME/.zshrc && source $HOME/.zshrc
}

es() {
  v $HOME/.config/shell/scripts/ "$@"
}

# Config inspection
bz() {
  bat $HOME/.zshrc "$@"
}

ba() {
  bat $HOME/.config/shell/aliases.zsh "$@"
}

