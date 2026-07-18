This repo bootstraps work environment on Ubuntu VPS

`symlinks` lists files tracked from outside of repo.
Format - `dest<TAB>source`.
Pre-commit hook copies fresh content from each source into repo and stages it.
Setup hook after clone - git config core.hooksPath .githooks

Example how to add new symlink:
./add-symlink tools/starship.toml /Users/vic/.config/starship.toml
