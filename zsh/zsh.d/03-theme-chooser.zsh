#!/bin/zsh
if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]] ; then
      eval "$(oh-my-posh --init --shell zsh --config ~/.config/dot-files/posh/nord.omp.json)"
      enable_poshtransientprompt
elif [[ "$NF_SAFE" == "false" ]]; then
      eval "$(oh-my-posh --init --shell bash --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/ys.omp.json)"
else
      eval "$(oh-my-posh --init --shell zsh --config ~/.config/dot-files/posh/nord.omp.json)"
      enable_poshtransientprompt
fi
