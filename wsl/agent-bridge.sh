#!/bin/bash
winuser=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe '$env:UserName')
winuser=${winuser//$'\r'}
winhome="/mnt/c/Users/$winuser"
wingnupghome="C:/Users/$winuser/AppData/Local/gnupg"
gpgagentsocket="${XDG_RUNTIME_DIR}gnupg/S.gpg-agent"
gpgconnectagent="/mnt/c/Program Files (x86)/GnuPG/bin/gpg-connect-agent.exe"
# Configure ssh forwarding
export SSH_AUTH_SOCK=$HOME/.1password/agent.sock

# 1password SSH
op-ssh-socket() {
    # need `ps -ww` to get non-truncated command for matching
    # use square brackets to generate a regex match for the process we want but that doesn't match the grep command running it!
    ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"; echo $?)
    if [[ $ALREADY_RUNNING != "0" ]]; then
        if [[ -S $SSH_AUTH_SOCK ]]; then
            # not expecting the socket to exist as the forwarding command isn't running (http://www.tldp.org/LDP/abs/html/fto.html)
            #echo "removing previous socket..."
            rm $SSH_AUTH_SOCK
        fi
        #echo "Starting SSH-Agent relay..."
        # setsid to force new session to keep running
        # set socat to listen on $SSH_AUTH_SOCK and forward to npiperelay which then forwards to openssh-ssh-agent on windows
        (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
    fi
}

# GPG Socket
gpg-socket() {
    # GPG Socket
    # Removing Linux GPG Agent socket and replacing it by link to wsl2-ssh-pageant GPG socket
    ALREADY_RUNNING=$(ps auxww | grep -q "[n]piperelay.exe -ep -ei -s -a"; echo $?)
    if [[ $ALREADY_RUNNING != "0" ]]; then
        if ss -a | grep -q "$gpgagentsocket"; then
            #echo "removing previous gnupg socket"
            rm -rf "$gpgagentsocket"
        fi
        
        # Make sure GPG agent connect is running
        "$gpgconnectagent" /bye > /dev/null 2>&1

        #echo "Starting GnuPG Agent Relay..."
        (setsid socat UNIX-LISTEN:$gpgagentsocket,fork EXEC:"npiperelay.exe -ep -ei -s -a '${wingnupghome}/S.gpg-agent'",nofork &) > /dev/null 2>&1
    fi
}

function checkdeps() {
  local deps=(socat npiperelay.exe "${gpgconnectagent}")
  local dep
  local out
  for dep in "${deps[@]}"; do
    if ! out=$(type "$dep" 2>&1); then
      printf -- "Dependency %s not found:\n%s\n" "$dep" "$out"
      return 1
    fi
  done
}

checkdeps
op-ssh-socket
gpg-socket
