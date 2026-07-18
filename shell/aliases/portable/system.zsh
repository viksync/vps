# split path by : and join with \n
ep() {
  echo $PATH | tr ':' '\n'
}

w() { which "$@" }

# Sudo
_() { sudo "$@" }

# Repeat previous with sudo
f() { sudo "$(fc -ln -1)"; }

# Repeat previous command
j() { fc -s }

clr() { clear }


# ===============================
# processes
# ===============================

psp() {
  ps -p $1 -o pid,ppid,user,command
}

