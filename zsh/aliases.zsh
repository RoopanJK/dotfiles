# Aliases.

alias d="kitten diff"
alias icat="kitten icat"

# `kitten ssh` only works from inside kitty. Guarding it means a tty, a nested
# ssh session, or another terminal falls through to the real ssh instead of
# failing.
[[ -n $KITTY_WINDOW_ID ]] && alias ssh="kitten ssh"

alias nvtop='TERM=xterm-256color nvtop'
