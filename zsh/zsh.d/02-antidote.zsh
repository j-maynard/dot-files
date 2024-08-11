# !/bin/zsh
# Activate antibody
#source <(antibody init)
#antibody bundle < ~/.zsh_plugins.txt

if [[ $(uname) == "Linux" ]]; then
    source ~/.antidote/antidote.zsh
else
    source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
fi
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
    antidote load
  )
fi
source ${zsh_plugins}.zsh
