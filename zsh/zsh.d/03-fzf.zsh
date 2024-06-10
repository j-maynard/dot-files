export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export PATH=~/.fzf/bin:$PATH

if [[ $(uname) == "Darwin" ]]; then
  [[ $- == *i* ]] && source  "/opt/homebrew/opt/fzf/shell/completion.zsh"  2> /dev/null
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
else
  [[ $- == *i* ]] && source "${HOME}/.fzf/shell/completion.zsh" 2> /dev/null
  source "${HOME}/.fzf/shell/key-bindings.zsh"
fi

