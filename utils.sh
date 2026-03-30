#!/usr/bin/env bash
# Shared helpers for bootstrap scripts. Source this file; do not execute directly.

ok()   { printf "\033[32m✓\033[0m %s\n" "$1"; }
info() { printf "\033[34m→\033[0m %s\n" "$1"; }
err()  { printf "\033[31m✗\033[0m %s\n" "$1" >&2; }

# spin "label" cmd [args...]
# Runs cmd silently with a braille spinner.
# Prints "✓ label" on success or "✗ label" + captured output on failure.
spin() {
  local label="$1"; shift
  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  local output i=0 exit_code=0 pid
  output=$(mktemp)

  "$@" >"$output" 2>&1 &
  pid=$!

  tput civis 2>/dev/null || true
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r%s %s " "${frames[i]}" "$label"
    i=$(( (i + 1) % ${#frames[@]} ))
    sleep 0.08
  done
  tput cnorm 2>/dev/null || true

  wait "$pid" || exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    printf "\r\033[32m✓\033[0m %s\n" "$label"
  else
    printf "\r\033[31m✗\033[0m %s\n\n" "$label"
    cat "$output"
  fi

  rm -f "$output"
  return $exit_code
}

# Run a command as VPS_USER with correct HOME.
# Requires VPS_USER to be set in the calling script.
as_user() {
  sudo -u "$VPS_USER" env HOME="/home/$VPS_USER" PATH="/home/$VPS_USER/.local/bin:$PATH" \
    bash -c 'cd "$HOME" && exec "$@"' -- "$@"
}

# gh_install <owner/repo> <asset-regex> <binary-name>
# Downloads the latest GitHub release asset matching regex, extracts <binary-name>,
# and installs it to /home/$VPS_USER/.local/bin. Requires: VPS_USER, jq, curl.
gh_install() {
  local repo="$1" pattern="$2" binary="$3"
  local dest="/home/$VPS_USER/.local/bin"
  mkdir -p "$dest"

  local release_json url tmp found
  release_json=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest")
  url=$(printf '%s' "$release_json" \
    | jq -r --arg p "$pattern" \
      '.assets[] | select(.name | test($p)) | .browser_download_url' \
    | head -1)

  [[ -z "$url" ]] && { err "No asset matching '$pattern' in $repo"; return 1; }

  tmp=$(mktemp -d)

  curl -fsSL "$url" -o "$tmp/asset"

  case "$url" in
    *.tar.gz|*.tgz) tar -xf "$tmp/asset" -C "$tmp" ;;
    *.zip)          unzip -q "$tmp/asset" -d "$tmp" ;;
  esac

  found=$(find "$tmp" -name "$binary" -type f | head -1)
  [[ -z "$found" ]] && found="$tmp/asset"  # raw binary (no archive)

  install -m 755 "$found" "$dest/$binary"
  chown "$VPS_USER:$VPS_USER" "$dest/$binary"
  rm -rf "$tmp"
}

# symlink <src> <dst>
symlink() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
}
