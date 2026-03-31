_ALIASES="$HOME/.config/shell/aliases"

for _f in "$_ALIASES"/portable/*.zsh; do
  source "$_f"
done
unset _f

unset _ALIASES
