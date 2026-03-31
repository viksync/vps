# ===============================
# GIT
# ===============================

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

glot() {
  git log --all --author="$(git config user.name)" --since=midnight --oneline
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

gps() {
  local output
  output=$(git push 2>&1)
  local status=$?

  echo "$output"

  if [[ $status -ne 0 ]]; then
    local cmd
    cmd=$(echo "$output" | grep -Eo "git push --set-upstream origin [^[:space:]]+")

    if [[ -n "$cmd" ]]; then
      echo "\n⚡ Running suggested upstream command:"
      echo "$cmd"
      eval "$cmd"
    fi
  fi

  return $status
}
