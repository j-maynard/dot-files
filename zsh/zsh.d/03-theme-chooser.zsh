#!/bin/zsh
#!/bin/zsh
export MANUFACTURER=unknown
if [[ -v WSLENV ]]; then
      export MANUFACTURER=$(powershell.exe -command "(Get-WmiObject -Class:Win32_ComputerSystem).Manufacturer")
elif [ -f /sys/devices/virtual/dmi/id/sys_vendor ]; then
      export MANUFACTURER=$(cat /sys/devices/virtual/dmi/id/sys_vendor)
fi

if [[ "$TERMINAL_EMULATOR" == "JetBrains-JediTerm" ]] ; then
      eval "$(oh-my-posh init zsh --config ~/.config/dot-files/posh/nord.omp.json)"
      enable_poshtransientprompt
      enable_poshtooltips
elif [[ "$NF_SAFE" == "false" ]]; then
      eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/ys.omp.json)"
else
      eval "$(oh-my-posh init zsh --config ~/.config/dot-files/posh/nord.omp.json)"
      enable_poshtransientprompt
      enable_poshtooltips
fi
