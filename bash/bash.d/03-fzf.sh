#!/bin/bash
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${HOME}/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "${HOME}/.fzf/shell/key-bindings.bash"
