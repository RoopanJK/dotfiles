# History. This is the file that fixes suggestion quality.

HISTFILE=$HOME/.zsh_history
HISTSIZE=200000
# Was SAVEHIST=10000 against HISTSIZE=50000, so the on-disk history was being
# silently truncated to a fifth of what the shell held — and the truncated file
# is what autosuggestions read from.
SAVEHIST=$HISTSIZE

setopt EXTENDED_HISTORY       # record timestamp and duration
setopt SHARE_HISTORY          # live sharing between open shells
setopt HIST_IGNORE_SPACE      # a leading space keeps a command out of history
setopt HIST_IGNORE_DUPS       # don't record an immediately repeated command
setopt HIST_EXPIRE_DUPS_FIRST # trim duplicates before unique entries
setopt HIST_FIND_NO_DUPS      # searching doesn't show the same line twice
setopt HIST_REDUCE_BLANKS     # tidy whitespace before storing
setopt HIST_VERIFY            # expand !! to the line rather than running it
setopt HIST_NO_STORE          # don't store `history` calls themselves
