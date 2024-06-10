# !/bin/zsh
# Activate antibody
#source <(antibody init)
#antibody bundle < ~/.zsh_plugins.txt

source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
zsh_plugins=${ZDOTDIR:-$HOME}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source /path-to-antidote/antidote.zsh
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi
source ${zsh_plugins}.zsh
