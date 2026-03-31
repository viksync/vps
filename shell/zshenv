[[ -f $HOME/.config/shell/zshenv.local ]] && source $HOME/.config/shell/zshenv.local

# PATH is managed in .zprofile (single source of truth)

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

export EDITOR='nvim'
export BAT_THEME="TwoDark"

export scripts='$HOME/.config/shell/scripts/'
export l="localhost:3000"

# Suppress history in REPL tools
export NODE_REPL_HISTORY=""
export LESSHISTFILE=-

# ----------------------------------------
# Homebrew
# ----------------------------------------

export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_AUTO_UPDATE_SECS=86400
export HOMEBREW_NO_INSTALL_UPGRADE=1
export HOMEBREW_NO_UPDATE_REPORT_FORMULAE=1
export HOMEBREW_NO_UPDATE_REPORT_CASKS=1

# ----------------------------------------
# Claude Code / OpenTelemetry
# ----------------------------------------

export CLAUDE_CODE_ENABLE_TELEMETRY=1

export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp

export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317

export OTEL_METRIC_EXPORT_INTERVAL=10000
# 10 seconds (default: 60000ms)
export OTEL_LOGS_EXPORT_INTERVAL=5000
# 5 seconds (default: 5000ms)
