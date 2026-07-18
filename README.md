# VPS bootstrap

This repository bootstraps an Ubuntu VPS and keeps selected local configuration files under version control.

## Run the bootstrap

From a clone on the VPS, run the orchestrator as root:

```bash
sudo ./main.sh <ssh-port> <username>
```

The port is used to configure the SSH listener and firewall rule, while the username identifies the non-root account that receives SSH access, sudo, tools, and shell configuration.

## Individual scripts

The rows are in `main.sh` execution order. `utils.sh`, `add-symlink`, and the hook are supporting scripts, so they follow the bootstrap sequence.

| Script | What it does, in execution order |
| --- | --- |
| `main.sh` | - Requires root and validates `<ssh-port>` (1024–65535) and `<username>`.<br>- Loads `utils.sh`, exports `SSH_PORT`, `VPS_USER`, and `NEW_USER`.<br>- Updates/upgrades apt and installs `curl`, UFW, build tools, `unzip`, and zsh.<br>- Runs `01-tailscale.sh`, then exports its Tailscale IPv4 address as `TS_IP`.<br>- Runs `02-user.sh`; if necessary, copies this repo into the new user's home so user-level steps can read it.<br>- Runs `03-ssh-keys.sh`, `04-sshd.sh`, and `05-ufw.sh`.<br>- Shows the effective SSH/UFW configuration and waits for a successful new SSH login.<br>- Runs `06-packages.sh` and `07-docker.sh` as root.<br>- Runs `08-shell.sh`, `09-tools.sh`, and `10-nvim.sh` as the new user.<br>- Sets zsh as the new user's login shell. |
| `01-tailscale.sh` | - Requires root.<br>- Installs Tailscale using its install script.<br>- Runs `tailscale up --advertise-tags=tag:vps` and waits for browser authentication.<br>- Reads and verifies the Tailscale IPv4 address. |
| `02-user.sh` | - Requires root and `NEW_USER`.<br>- Creates the `sshu` group if needed.<br>- Creates the user if missing and prompts for its password.<br>- Adds the user to `sshu` and `sudo`.<br>- Creates `.ssh/authorized_keys` with correct ownership and permissions.<br>- Prompts for a public key and appends it only if it has an `ssh-` prefix. |
| `03-ssh-keys.sh` | - Requires root and `NEW_USER`.<br>- Creates the new user's `.ssh` directory.<br>- Copies `/root/.ssh/vps_github` and `vps_github.pub` when present.<br>- Copies `/root/.ssh/config` when present.<br>- Applies restrictive ownership and permissions, restoring `vps_github.pub` to readable public-key permissions. |
| `04-sshd.sh` | - Requires root, `SSH_PORT`, and `TS_IP`.<br>- Backs up an existing hardening drop-in.<br>- Writes a temporary SSH configuration: selected port, Tailscale listener, public-key-only authentication, `sshu` access, hardened crypto, and forwarding/keepalive limits.<br>- Validates the merged SSH configuration before replacing the live drop-in.<br>- Stops, disables, and masks SSH socket units if present.<br>- Enables and restarts the SSH service.<br>- Verifies that SSH reports the selected port. |
| `05-ufw.sh` | - Requires root and `SSH_PORT`.<br>- Resets UFW.<br>- Sets incoming traffic to deny and outgoing traffic to allow.<br>- Allows public TCP ports 80 and 443.<br>- Allows the selected SSH port only on `tailscale0`.<br>- Explicitly denies that SSH port elsewhere and enables UFW. |
| `06-packages.sh` | - Requires `VPS_USER` and creates its `.local/bin` and `.local/share` directories.<br>- Installs apt packages: Git, jq, and pipx.<br>- Installs GitHub CLI from GitHub's apt repository when absent.<br>- Installs Node.js LTS from NodeSource when absent.<br>- Installs `bat`, `eza`, `fd`, `fzf`, `jid`, `lazydocker`, `lazygit`, `rg`, `yazi`, `ya`, `zellij`, and `zoxide` from GitHub releases when absent.<br>- Installs Neovim and links its binary into `.local/bin` when absent.<br>- Installs rtk, httpie, Bun, and Claude Code for the VPS user when absent. |
| `07-docker.sh` | - Requires `VPS_USER`; exits early when Docker already exists.<br>- Adds Docker's official apt repository.<br>- Installs Docker CE, CLI, containerd, Buildx, and Compose.<br>- Writes `/etc/docker/daemon.json` with the local driver and a 10 MB log limit.<br>- Enables Docker and containerd.<br>- Adds the user to the `docker` group. |
| `08-shell.sh` | - Runs as the VPS user.<br>- Creates shell, cache, and local binary/share directories.<br>- Creates live links from repository shell files to `.zprofile`, `.zshenv`, `.zshrc`, p10k, aliases, and portable aliases in `$HOME`.<br>- Installs Zinit when absent.<br>- Prints how to load the new shell configuration. |
| `09-tools.sh` | - Runs as the VPS user.<br>- Creates Yazi and Zellij config directories.<br>- Creates live links for the three Yazi files and Zellij's `config.kdl`.<br>- Runs `ya pkg install` to install Yazi packages. |
| `10-nvim.sh` | - Runs as the VPS user.<br>- Creates `$HOME/.config`.<br>- Clones `git@github.com:viksync/nvim.git` into `.config/nvim` if it is absent.<br>- Runs `nvim --headless "+Lazy! sync" +qa` to synchronize plugins. |
| `utils.sh` | - Is sourced by the bootstrap scripts before their work starts.<br>- Provides colored status messages and a command spinner.<br>- Provides `as_user` to run commands as `VPS_USER` with its HOME and local bin path.<br>- Provides `gh_install` for release binaries and `symlink` for `ln -sf` links. |
| `add-symlink` | - Validates a repository-relative destination and existing absolute source.<br>- Rejects duplicate manifest destinations.<br>- Appends the `dest<TAB>source` pair to `symlinks`.<br>- Copies the source into the repository immediately. |
| `.githooks/pre-commit` | - Runs before each commit when `core.hooksPath=.githooks`.<br>- Reads every `dest<TAB>source` entry from `symlinks`.<br>- Replaces each repository destination with the current external file or directory.<br>- Stages every refreshed destination. |

## Config tracking and live links

There are two related mechanisms:

1. `08-shell.sh` and `09-tools.sh` create live symlinks from the VPS user's configuration paths to files in this repository.
2. The `symlinks` manifest is for local configuration snapshots. With `core.hooksPath` set to `.githooks`, every commit copies each external source into its matching repository destination and stages it.

To add another tracked external config:

```bash
./add-symlink path/in/repo /absolute/path/to/local/config
git add path/in/repo symlinks
```

## Current tracked external configs

| Repository destination    | External source                    |
| ------------------------- | ---------------------------------- |
| `tools/zellij.kdl`        | `~/.config/zellij/config.kdl`      |
| `tools/yazi/package.toml` | `~/.config/yazi/package.toml`      |
| `tools/yazi/yazi.toml`    | `~/.config/yazi/yazi.toml`         |
| `tools/yazi/theme.toml`   | `~/.config/yazi/theme.toml`        |
| `shell/p10k.zsh`          | `~/.config/p10k/p10k.zsh`          |
| `shell/aliases.base.zsh`  | `~/.config/shell/aliases.base.zsh` |
| `shell/zshenv`            | `~/.config/shell/zshenv`           |
| `shell/zshrc.base`        | `~/.config/shell/zshrc.base`       |
| `shell/scripts`           | `~/.config/shell/scripts`          |
| `shell/aliases/portable`  | `~/.config/shell/aliases/portable` |
