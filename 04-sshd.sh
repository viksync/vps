#!/usr/bin/env bash
set -euo pipefail
# Writes SSH hardening config and restarts sshd.
# Requires: SSH_PORT, TS_IP env vars

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$REPO_DIR/utils.sh"

if [[ $EUID -ne 0 ]]; then
  err "Run this as root"
  exit 1
fi

: "${SSH_PORT:?SSH_PORT not set}"
: "${TS_IP:?TS_IP not set}"

DROPIN_DIR="/etc/ssh/sshd_config.d"
CONFIG_FILE="${DROPIN_DIR}/99-hardening.conf"
BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%s)"
TMP_FILE="/tmp/99-hardening.conf"

# ── Hardening config ──────────────────────────────────────────
mkdir -p "$DROPIN_DIR"

[[ -f "$CONFIG_FILE" ]] && cp "$CONFIG_FILE" "$BACKUP_FILE"

cat >"$TMP_FILE" <<EOF
Port ${SSH_PORT}
ListenAddress ${TS_IP}

LogLevel VERBOSE

# Authentication
LoginGraceTime 10
MaxAuthTries 3
MaxSessions 5

PubkeyAuthentication yes
AuthenticationMethods publickey
AuthorizedKeysFile .ssh/authorized_keys

PasswordAuthentication no
PermitEmptyPasswords no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no

UsePAM no
PermitRootLogin prohibit-password

# Restrict access
AllowGroups sshu

# Crypto
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com

# Hardening
X11Forwarding no
AllowTcpForwarding yes
AllowAgentForwarding no
PermitTunnel no
PermitUserEnvironment no

# Keepalive
ClientAliveInterval 120
ClientAliveCountMax 2

# Misc
PrintMotd no
AcceptEnv LANG LC_* COLORTERM NO_COLOR
EOF

spin "Validating SSH config" bash -c "
  merged=\$(mktemp)
  cat /etc/ssh/sshd_config '${TMP_FILE}' > \"\$merged\"
  sshd -t -f \"\$merged\"
  rm -f \"\$merged\"
"

cp "$TMP_FILE" "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"
rm -f "$TMP_FILE"
ok "SSH hardening config applied"

# ── Service ───────────────────────────────────────────────────
if systemctl list-unit-files ssh.service &>/dev/null; then
  SSH_SVC="ssh"
else
  SSH_SVC="sshd"
fi

spin "Configuring SSH service" bash -c "
  for unit in ssh.socket sshd.socket; do
    if systemctl list-unit-files \"\$unit\" &>/dev/null; then
      systemctl stop \"\$unit\" 2>/dev/null || true
      systemctl disable \"\$unit\" 2>/dev/null || true
      systemctl mask \"\$unit\" 2>/dev/null || true
    fi
  done
  systemctl enable --now '${SSH_SVC}'
  systemctl restart '${SSH_SVC}'
"

sleep 2

# ── Verify ────────────────────────────────────────────────────
ACTUAL_PORT=$(sshd -T 2>/dev/null | awk '/^port / {print $2}' | head -n1)
ACTUAL_ADDR=$(sshd -T 2>/dev/null | awk '/^listenaddress/ {print $2}' | head -n1)

if [[ "$ACTUAL_PORT" != "$SSH_PORT" ]]; then
  err "sshd is on port ${ACTUAL_PORT}, expected ${SSH_PORT}"
  err "Socket activation may still be interfering. Check:"
  err "    systemctl list-units --type=socket | grep ssh"
  exit 1
fi

ok "sshd listening on ${ACTUAL_ADDR} port ${ACTUAL_PORT}"

if [[ -f "$BACKUP_FILE" ]]; then info "Old config backed up: ${BACKUP_FILE}"; fi
