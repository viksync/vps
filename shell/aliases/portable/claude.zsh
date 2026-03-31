# ===============================
# Claude
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
