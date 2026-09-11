# Plugins, via znap.
#
# The order below is load-bearing, and getting it wrong is the usual cause of
# completion "just feeling broken":
#   1. prompt first, so it renders before the rest finishes loading
#   2. anything contributing to fpath before completion is configured
#   3. fzf-tab after the completion styles, before anything that wraps widgets
#   4. syntax highlighting last — it wraps widgets and has to see them all

[[ -r ~/zsh_snap/znap/znap.zsh ]] ||
  git clone --depth 1 -- \
    https://github.com/marlonrichert/zsh-snap.git ~/zsh_snap/znap
source ~/zsh_snap/znap/znap.zsh

znap prompt sindresorhus/pure

# oh-my-zsh is no longer loaded as a framework — it was the single biggest
# startup cost (24 _omz_source calls, ~23% of startup) and a second compinit
# caller, for three plugins. znap sources just those three instead.
#
# lib/functions.zsh comes along because web-search calls omz_urlencode and
# open_command from it. git needs is-at-least, which is a stock zsh function.
autoload -Uz is-at-least
znap source ohmyzsh/ohmyzsh \
  lib/functions.zsh \
  plugins/git \
  plugins/sudo \
  plugins/web-search

znap source zsh-users/zsh-completions          # contributes to fpath

source $ZSH_CONFIG_DIR/completion.zsh

# fzf's own integration goes in BEFORE fzf-tab. `fzf --zsh` binds Tab to
# fzf-completion, which would otherwise clobber fzf-tab's Tab binding; loading
# it first leaves fzf-tab's binding last and keeps fzf's ^R / ^T / alt-c.
(( $+commands[fzf] )) && eval "$(fzf --zsh)"

znap source Aloxaf/fzf-tab
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-syntax-highlighting

# The always-on dropdown. It loads after syntax highlighting, per its README.
#
# This was removed once and put back: it turned out not to be the reason shells
# were slow. That was the double compinit rebuilding the completion dump on
# every start; with that fixed, this plugin costs nothing measurable (273ms to
# first prompt either way). It does rebind Tab and ^R, which keybinds.zsh
# reasserts afterwards.
znap source marlonrichert/zsh-autocomplete

# Removed: `znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'`
# iTerm2 is macOS-only. On Linux it did nothing but emit OSC 1337 sequences
# into command output, and made first-run startup depend on the network.
# Removed: a pyenv lazy-load and a `compctl -K _pyenv pyenv` line, for a pyenv
# that is not installed on this machine. (compctl is also the pre-compsys
# completion system.)

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
