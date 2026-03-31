# ===============================
# Directories
# ===============================

md() {
  s mkdir -p "$@"
}

# create dir and cd to it
function mdc() {
  mkdir -p "$1" && cd "$1"
}

rmd() {
  s rm -r "$@"
}

rmf() {
  s rm -rf "$@"
}
