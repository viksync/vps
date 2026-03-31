This repo bootstraps work environment on Ubuntu VPS

## Dev setup (once per clone)

```
git config core.hooksPath .githooks
git ls-files | xargs -I{} sh -c 'test -L {} && git update-index --skip-worktree {}' 2>/dev/null; true
```

`shell/` and `tools/` contain symlinks to the local dotfiles. The pre-commit hook
materializes them into real file content in the git index so the VPS receives
actual files on clone. Working-tree symlinks are never modified.
