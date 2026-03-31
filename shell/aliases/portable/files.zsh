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
