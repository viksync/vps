# ===============================
# SYSTEM & SHELL
# ===============================

# Source & reload configs

# so → source + command
soz() {
  source $HOME/.zshrc "$@"
}

soa() {
  source $HOME/.config/shell/aliases.zsh "$@"
}

# e → edit + command
ea() {
  nvim $HOME/.config/shell/aliases.zsh && source $HOME/.config/shell/aliases.zsh
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

# split path by : and join with \n
ep() {
  echo $PATH | tr ':' '\n'
}

w() {
  which "$@"
}

# Sudo
_() {
  sudo "$@"
}

# Repeat previous with sudo
f() { sudo "$(fc -ln -1)"; }

# Repeat previous command
j() { fc -s }

cl() { clear }

# ===============================
# FILES
# ===============================
# fi → file + command

# file size 
fis() {
  du -sh "$@"
}

# show number of files in current dir
fin() {
    local dir="${1:-.}"
    ls -A "$dir" 2>/dev/null | wc -l | xargs
}

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

chd() {
  if [[ $# -lt 4 ]]; then
    echo "Usage: chd DD MM YY|YYYY file..."
    return 1
  fi

  local dd mm yyyy
  dd=$(printf "%02d" $1)
  mm=$(printf "%02d" $2)

  # Handle year
  if [[ ${#3} -eq 2 ]]; then
    yyyy="20$3"
  elif [[ ${#3} -eq 4 ]]; then
    yyyy="$3"
  else
    echo "Invalid year: $3 (use YY or YYYY)"
    return 1
  fi

  shift 3

  # Basic validation
  if (( mm < 1 || mm > 12 )); then
    echo "Invalid month: $mm"
    return 1
  fi

  if (( dd < 1 || dd > 31 )); then
    echo "Invalid day: $dd"
    return 1
  fi

  local ts="${yyyy}${mm}${dd}0000"

  for f in "$@"; do
    touch -t "$ts" "$f" || echo "Failed: $f"
  done
}

# touch executable + vim
te() {
  local file="$1"
  if [[ -z "$file" ]]; then
    echo "Usage: te <filename>"
    return 1
  fi
  touch "$file" && chmod +x "$file" && nvim "$file"
}

# prepend to file
# usage: pre "text" filename
pre() {
  local text=$1
  local file=$2

  [[ -z $text || -z $file ]] && { echo "Usage: pre \"text\" filename"; return 1 }
  [[ ! -f $file ]] && { echo "File not found: $file"; return 1 }

  # Prepend text and overwrite file atomically
  { echo "$text"; cat "$file"; } > "${file}.tmp" && mv "${file}.tmp" "$file"
}

# ===============================
# Fuzzy
# ===============================

# fuzzy + bat preview
fzp() {
  fzf --preview="bat --color=always {}" "$@"
}

# fuzzy + open in vim
fzv() {
  nvim $(fzf -m --preview="bat --color=always {}") "$@"
}

# ===============================
# Execution
# ===============================

# execute with arguments
function x() {
  local file="$1"
  shift  # remove the first argument so "$@" contains the rest

  # Check if file exists and is executable
  if [[ -f "$file" && -x "$file" ]]; then
    # Run it with any additional arguments
    "./$file" "$@"
  elif [[ -f "$file" ]]; then
    echo "File exists but is not executable: $file" >&2
    return 1
  else
    echo "File not found: $file" >&2
    return 1
  fi
}

# Make executable
mx() {
  chmod +x "$@"
}

# make executable and execute with arguments
function mxx() {
  local file="$1"
  shift  # remaining args for the script

  if [[ -f "$file" ]]; then
    chmod +x "$file"  # make it executable
    x "$file" "$@"    # call your existing x function with all remaining args
  else
    echo "File not found: $file"
    return 1
  fi
}


# ===============================
# ls → eza
# ===============================

# wihout -l it does nothing, with -l shows folder size
# e() {
#   eza --total-size "$@"
# }

ls() {
  eza "$@"
}

# tree with node_modules ignored by default when level >= 2
lt() {
    local level=1

    # if first argument is a number, treat it as level
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        level="$1"
        shift  # only safe to shift here
    fi

    # build command
    local cmd=(eza --tree --level="$level")
    if (( level >= 2 )); then
        cmd+=(-I node_modules)
    fi
    cmd+=("$@")  # add any extra flags

    "${cmd[@]}"
}

# show only dot items
lsd() {
  eza -d .* -f "$@"
}


# ===============================
# Symlinks
# ===============================

lns() {
  ln -s "$@"
}

# ln -s for all arguments separately
lnsm() {
    for f in "$@"; do
        local base="${f##*/}"   # strip path, keep filename
        ln -s "$f" "$base"
    done
}


# ===============================
# Preview
# ===============================

b() {
  bat "$@"
}

bw() {
  local width="${1:-80}"
  bat --terminal-width="$width" "${@:2}"
}


# ===============================
# Navigation
# ===============================

# copy working dir
cwd() {
  pwd | xclip -selection clipboard
}

# Directory shortcuts
function ..() { cd .. }
function ...() { cd ../.. }
function ....() { cd ../../.. }
function .....() { cd ../../../.. }
function cd-() { cd - > /dev/null }
function ~() { cd $HOME }

zp() {
  z $HOME/Projects/ "$@"
}

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

# ===============================
# DEVELOPMENT TOOLS
# ===============================

# ==========
# EDITORS
# ==========

v() {
  nvim "$@"
}

vc() {
  nvim $HOME/.config/nvim/ "$@"
}

vk() {
  nvim $HOME/.config/nvim/lua/config/keymaps.lua "$@"
}

# ==========
# NODE.JS
# ==========

n() {
  node "$@"
}

nv() {
  node --version "$@"
}

# ==========
# PYTHON
# ==========

python() {
  python3 "$@"
}

pip() {
  pip3 "$@"
}

# ==========
# GIT
# ==========

g() {
  git "$@"
}

gs() {
  git status -s "$@"
}

gsl() {
  git status "$@"
}

gl() {
  git log "$@"
}

gll() {
  git log -1 "$@"
}

glo() {
  git log --oneline "$@"
}

glon() {
  git log --oneline --no-decorate "$@"
}

gp() {
  git push "$@"
}

gpl() {
  git pull "$@"
}

ga() {
  git add "$@"
}

gam() {
  git commit -a -m "$@"
}

gaa() {
  git add * "$@"
}

gar() {
  git add . "$@"
}

gu() {
  git add -u "$@"
}

gsc() {
  git config --list --show-origin "$@"
}

gan() {
  git commit -a --amend --no-edit "$@"
}

# Dotfiles management
# dots() {
#   git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME "$@"
# }


# ==========
# ZELLIJ
# ==========

ze() {
  zellij "$@"
}

# ===============================
# PACKAGE MANAGERS
# ===============================

# npm
# ==========

nlg() {
  npm list -g "$@"
}

nig() {
  s npm install -g "$@"
}

nu() {
  s npm install -g npm@latest "$@"
}

nug() {
  s npm update -g "$@"
}

npv() {
  npm -v "$@"
}

# like brew leaves
nl() {
  npm ls -g --depth=0 --parseable | tail -n +2 | xargs -n 1 basename
}

nd() {
  npm run dev "$@"
}

pn() {
  pnpm "$@"
}


# ===============================
# tools
# ===============================


# yazi
# ==========

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
# ai
# ===============================

c() {
  claude "$@"
}

cr() {
  claude --resume
}

cn() {
    local lock_file
    lock_file=$(ls -t ~/.claude/ide/*.lock 2>/dev/null | head -1)

    if [[ -z "$lock_file" ]]; then
      echo "No claudecode.nvim server found. Is Neovim open?" >&2
      return 1
    fi

    local port
    port=$(basename "$lock_file" .lock)

    echo "Connecting to Neovim on port $port..."
    CLAUDE_CODE_SSE_PORT="$port" ENABLE_IDE_INTEGRATION=true claude "$@"
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
# networking
# ===============================


# ===============================
# Docker
# ===============================

dcd() {
  docker compose down
}

dcu() {
  docker compose up
}
