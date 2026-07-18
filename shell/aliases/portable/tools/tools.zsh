# ===============================
# yazi
# ===============================

# open without changing current dir
# ya() {
#   yazi "$@"
# }

# change the dir to chosen in yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}


# ===============================
# webdev
# ===============================

cul() {
  curl localhost:3000$1
}

hl() {
  http localhost:3000$1
}

ph() {
  local url

  url=$(pbpaste)

  if [[ -z "$url" ]]; then
    echo "Clipboard is empty"
    return 1
  fi

  s yt-dlp "$url" -P ~/Movies/ph
}
