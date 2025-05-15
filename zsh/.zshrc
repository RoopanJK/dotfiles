#export ROS_LOCALHOST_ONLY=1
#export ROS_DOMAIN_ID=1

# If you come from bash you might have to change your $PATH.
export PATH=/home/jin/.local/bin:$HOME/bin:/usr/local/bin:$HOME/development/flutter/bin:$HOME/development/flutter/bin/dart-sdk/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequency 13

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git sudo web-search)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Alias setup
alias rsw="source /opt/ros/humble/setup.zsh"

alias d="kitten diff"
alias ssh="kitten ssh"
alias icat="kitten icat"


[[ -r ~/zsh_snap/znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/zsh_snap/znap
source ~/zsh_snap/znap/znap.zsh  # Start Znap

# `znap prompt` makes your prompt visible in just 15-40ms!
znap prompt sindresorhus/pure

# `znap eval` makes evaluating generated command output up to 10 times faster.
znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

# `znap function` lets you lazy-load features you don't always need.
znap function _pyenv pyenv "znap eval pyenv 'pyenv init - --no-rehash'"
compctl -K    _pyenv pyenv

# `znap install` adds new commands and completions.
znap install zsh-users/zsh-completions zsh-users/zsh-syntax-highlighting zsh-users/zsh-autosuggestions

# `znap source` starts plugins.
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-syntax-highlighting # Start zsh-syntax-highlighting before zsh-autocomplete
znap source marlonrichert/zsh-autocomplete

# zoxide
eval "$(zoxide init zsh)"
