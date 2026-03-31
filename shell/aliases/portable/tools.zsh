# ===============================
# yazi
# ===============================

# open without changing current dir
y() {
  yazi "$@"
}

# change the dir to chosen in yazi
function yy() {
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


# ===============================
# processes
# ===============================

psp() {
  ps -p $1 -o pid,ppid,user,command
}

# ===============================
# ZELLIJ
# ===============================

ze() {
  zellij "$@"
}
