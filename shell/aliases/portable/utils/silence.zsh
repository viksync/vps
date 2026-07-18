ok() { printf "\033[32m✓\033[0m %s\n" "$1"; }
info() { printf "\033[34m→\033[0m %s\n" "$1"; }
err() { printf "\033[31m✗\033[0m %s\n" "$1" >&2; }

# spin "label" cmd [args...]
# Runs cmd silently with a braille spinner.
# Prints "✓ label" on success or "✗ label" + captured output on failure.

s() {
  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  local output i=0 exit_code=0 pid

  output=$(mktemp) || return 1

  setopt LOCAL_OPTIONS NO_MONITOR NO_NOTIFY 2>/dev/null

  { "$@" >"$output" 2>&1 } &
  pid=$!

  tput civis 2>/dev/null
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r%s " "${frames[i]}"
    i=$(( (i + 1) % ${#frames[@]} ))
    sleep 0.08
  done
  tput cnorm 2>/dev/null

  wait "$pid"
  exit_code=$?

  if (( exit_code == 0 )); then
    printf "\r\033[32m✓\033[0m\n"
  else
    printf "\r\033[31m✗\033[0m\n\n"
    cat "$output"
  fi

  rm -f "$output"
  return $exit_code
}
