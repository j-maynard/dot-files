export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export PATH=~/.fzf/bin:$PATH

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${HOME}/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "${HOME}/.fzf/shell/key-bindings.zsh"
