# .zshenv — read by every zsh, and crucially before /etc/zsh/zshrc.
#
# Ubuntu's /etc/zsh/zshrc runs compinit before ~/.zshrc has had a chance to add
# anything to fpath, so the dump it builds is missing every plugin completion.
# A second compinit then runs later and writes a different dump. /etc/zsh/zshrc
# documents the opt-out itself, and .zshenv is the only file early enough to
# set it.
skip_global_compinit=1

# XDG locations, so caches and state stop landing directly in $HOME.
: ${XDG_CONFIG_HOME:=$HOME/.config}
: ${XDG_CACHE_HOME:=$HOME/.cache}
: ${XDG_DATA_HOME:=$HOME/.local/share}
: ${XDG_STATE_HOME:=$HOME/.local/state}
export XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME

# -U keeps these deduplicated, so re-sourcing this file cannot grow PATH.
# Dropped from the old PATH: $HOME/bin and two $HOME/development/flutter paths,
# none of which exist on this machine.
typeset -U path PATH
path=(
  $HOME/.local/bin
  /usr/local/bin
  $path
)
export PATH
