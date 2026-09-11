# ROS 2 Jazzy.
#
# ROS_DOMAIN_ID is deliberately left unset, which means domain 0. If this
# machine ever shares a network with other ROS hosts, set it in local.zsh
# rather than here — it is a property of the network, not of the dotfiles.

export RCUTILS_COLORIZED_OUTPUT=1

alias rsw='source /opt/ros/jazzy/setup.zsh'

# colcon ships completion and colcon_cd with the debs, but nothing wires them
# up. Note we do NOT source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.zsh
# directly: its first line runs `compinit` eagerly, which would defeat znap's
# deferred compinit. Registering argcomplete ourselves through `znap eval` also
# caches the python invocation instead of paying for it on every shell start.
if (( $+commands[colcon] && $+commands[register-python-argcomplete] )); then
  autoload -Uz bashcompinit && bashcompinit
  znap eval colcon-argcomplete 'register-python-argcomplete colcon'
fi

if [[ -r /usr/share/colcon_cd/function/colcon_cd.sh ]]; then
  source /usr/share/colcon_cd/function/colcon_cd.sh
  export _colcon_cd_root=/opt/ros/jazzy
fi

alias cb='colcon build --symlink-install'
alias cbp='colcon build --symlink-install --packages-select'
alias cbu='colcon build --symlink-install --packages-up-to'
alias ct='colcon test'
alias ctr='colcon test-result --verbose'
