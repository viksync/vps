source $HOME/.config/shell/aliases.base.zsh

# ===============================
# Clipboard (Linux)
# ===============================

# copy file contents
fic() {
  xclip -selection clipboard < "$@"
}

# copy clipboard contents to a file
fip() {
  xclip -selection clipboard -o > "$@"
}

# copy file path
fipa() {
  local abs_path
  abs_path=$(realpath "$1" 2>/dev/null) || return
  printf "%s\n" "$abs_path" | tee >(xclip -selection clipboard)
}

# copy working dir
cwd() {
  pwd | xclip -selection clipboard
}
