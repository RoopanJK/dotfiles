# Shell behaviour.

setopt AUTO_CD               # `foo` cds into ./foo
setopt AUTO_PUSHD            # cd maintains a stack, browsable with `dirs -v`
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt EXTENDED_GLOB         # ^ # ~ in globs
setopt NUMERIC_GLOB_SORT     # file10 sorts after file9
setopt INTERACTIVE_COMMENTS  # allow # comments when typing commands
setopt LONG_LIST_JOBS
setopt NO_BEEP
setopt NO_FLOW_CONTROL       # frees ^S and ^Q for keybindings

# Deliberately NOT set: GLOB_DOTS. It makes * match dotfiles, which turns any
# `rm *` into a much bigger event than intended.

DIRSTACKSIZE=20
