g() {
  git "$@"
}

#------------------------
#       Status
# -----------------------

gs() {
  git status -s "$@"
}

gsl() {
  git status "$@"
}

#------------------------
#       Logs
# -----------------------

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


#------------------------
#       Switch
# -----------------------

gsw() {
  git switch "$@"
}

gswc() {
  git switch -c "$@"
}

g-() {
  git switch -
}

#------------------------
#       Push/Pull
# -----------------------

gp() {
  git push "$@"
}

gpl() {
  git pull "$@"
}

gps () {
    git push && return 0

    local branch
    branch=$(git branch --show-current)

    if [[ -n "$branch" ]]; then
        echo "⚡ Setting upstream for $branch"
        git push --set-upstream origin "$branch"
    fi
}

#------------------------
#       Add
# -----------------------

ga() {
  git add "$@"
}

gaa() {
  git add * "$@"
}

gar() {
  git add . "$@"
}

gau() {
  git add -u "$@"
}


#------------------------
#       Stash
# -----------------------

gst() {
  git stash
}

gstp() {
  git stash pop
}

gstl() {
  git stash list
}

gstp() {
  git stash push -m "$@"
}

#------------------------
#       Commit
# -----------------------

gcm() {
  git commit -m "$@"
}

gcam() {
  git commit -a -m "$@"
}

gca() {
  git commit --ammend "$@"
}

gcan() {
  git commit -a --amend --no-edit "$@"
}


#------------------------
#       Merge
# -----------------------

gm() {
  git merge "$@"
}

gmf() {
  git merge --ff-only "$@"
}

gmnf() {
  git merge --no-ff "$@"
}

#------------------------
#       Reset
# -----------------------

gr() {
  git reset "$@"
}

grs() {
  local target="HEAD"
  [[ -n "$1" ]] && target="HEAD~$1"
  git reset --soft "$target"
}

grh() {
  local target="HEAD"
  [[ -n "$1" ]] && target="HEAD~$1"
  git reset --hard "$target"
}

#------------------------
#       Config
# -----------------------

gsc() {
  git config --list --show-origin "$@"
}

#------------------------
#       Worktrees
# -----------------------

gwa() {
  git worktree add "$@"
}

gwr() {
  git worktree remove "$@"
}

gwl() {
  git worktree list
}
