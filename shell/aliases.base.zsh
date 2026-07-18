_ALIASES="$HOME/.config/shell/aliases"

for _f in "$_ALIASES"/portable/**/*.zsh(N); do
  source "$_f"
done

unset _f _ALIASES
