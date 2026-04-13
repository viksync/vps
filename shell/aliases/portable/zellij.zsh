za() {
  zellij attach "$@"
}

zc() {
  zellij attach -s "$@"
}

zl() {
  zellij ls
}

zw() {
  zellij kill-all-sessions
  rm -rf ~/.cache/zellij/sessions
  rm -rf ~/.cache/zellij
}
