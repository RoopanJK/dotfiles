# Key bindings.
#
# Sourced after plugins, which is what zsh-autocomplete's README recommends for
# overriding its keys. Kept small: the previous config bound nothing at all, and
# every binding here is a chance to break the dropdown.
#
# NOT set: `bindkey -e`. EDITOR and VISUAL are unset, so emacs is already the
# default keymap, and re-linking `main` after Autocomplete has installed its
# bindings is exactly what its README warns against.

if (( $+functions[.autocomplete__main] )); then
  # zsh-autocomplete owns up/down — those navigate its dropdown, and rebinding
  # them is what makes the dropdown feel broken.
  :
else
  # No dropdown: make up/down search history for what is already typed.
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey '^[[A' up-line-or-beginning-search
  bindkey '^[[B' down-line-or-beginning-search
  bindkey '^[OA' up-line-or-beginning-search
  bindkey '^[OB' down-line-or-beginning-search
fi

# Tab -> fzf-tab. Autocomplete claims Tab on load, so this has to come after.
(( $+functions[fzf-tab-complete] )) && bindkey '^I' fzf-tab-complete

# ^R -> fzf's fuzzy history, which beats a prefix search across a 200k-line
# history. Autocomplete claims ^R for its own history search; that remains
# reachable on alt+up (history menu), so nothing is actually lost here.
(( $+widgets[fzf-history-widget] )) && bindkey '^R' fzf-history-widget

# Word motions. NOTE: alt+left/right will not reach zsh until kitty stops
# binding them to neighboring_window — that is part of the kitty phase.
# Autocomplete uses alt+up/down for its menus; those are left untouched.
bindkey '^[[1;3D' backward-word     # alt+left
bindkey '^[[1;3C' forward-word      # alt+right
bindkey '^[[1;5D' backward-word     # ctrl+left
bindkey '^[[1;5C' forward-word      # ctrl+right
bindkey '^[^?'    backward-kill-word
bindkey '^[[3;5~' kill-word         # ctrl+delete
bindkey '^U'      backward-kill-line
bindkey '^[[3~'   delete-char
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
