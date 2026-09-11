# Completion styles.
#
# compinit is deliberately NOT called here. znap owns it: it defers compinit to
# the first precmd (which is how it gets a prompt up in tens of milliseconds),
# captures any compdef calls made before then, and afterwards replaces compinit
# with a no-op. Calling it here would either be ignored or defeat the deferral.
# znap also defaults its dump to $XDG_CACHE_HOME/zsh/compdump, so there is
# nothing to configure for that either.
#
# Sourced from plugins.zsh, not .zshrc, so it lands after the plugins that add
# to fpath and before the ones that wrap widgets.

zmodload -i zsh/complist

[[ -d $XDG_CACHE_HOME/zsh ]] || mkdir -p $XDG_CACHE_HOME/zsh

# Try exact, then case-insensitive, then partial word (f.b -> foo.bar), then
# substring. Ordered so the cheapest match that works is the one used.
zstyle ':completion:*' matcher-list \
  '' \
  'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# fzf-tab replaces the built-in menu, and requires the menu itself to be off.
zstyle ':completion:*' menu no

zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%F{blue}%B%d%b%f'
zstyle ':completion:*:messages'     format '%F{yellow}%d%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches%f'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' squeeze-slashes true

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/compcache

zstyle ':completion:*:*:kill:*:processes' command 'ps -u $USER -o pid,%cpu,cmd -w'
zstyle ':completion:*:*:kill:*' force-list always

# fzf-tab
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always -- $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color=always -- $realpath'

# zsh-autocomplete. Read at load time, so this has to come before plugins.zsh
# sources it.
zstyle ':autocomplete:*' min-input 1     # no dropdown on an empty line
zstyle ':autocomplete:*' delay 0.05      # brief debounce while typing
zstyle ':autocomplete:*:*' list-lines 8  # cap the dropdown height
zstyle ':autocomplete:history-search-backward:*' list-lines 8
