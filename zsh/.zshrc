# .zshrc — interactive shells.
#
# This file is a symlink into the dotfiles repo; :A resolves it so the modules
# beside it are found wherever the repo happens to live.
ZSH_CONFIG_DIR="${${(%):-%N}:A:h}"

# Order is load-bearing:
#   plugins  must come before ros, because wiring colcon's completion calls
#            compdef, and znap has to be loaded to capture it
#   keybinds comes after plugins so our explicit bindings win
() {
  local m
  for m in options history aliases plugins ros keybinds; do
    [[ -r $ZSH_CONFIG_DIR/$m.zsh ]] && source $ZSH_CONFIG_DIR/$m.zsh
  done
}

# Machine-specific settings, deliberately untracked. The *.local.zsh name is
# what .gitignore already excludes, and allows more than one override file.
() {
  local f
  for f in $ZSH_CONFIG_DIR/*.local.zsh(N); do source $f; done
}

true
