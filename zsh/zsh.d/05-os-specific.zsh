#!/bin/zsh
# OS Specific stuff goes here 
case $(uname) in
  Darwin)     PATH="/usr/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/2.6.0/bin:/usr/local/opt/coreutils/libexec/gnubin:$PATH"
              MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
              gpg-agent > /dev/null 2>&1
              if [[ $? -ne 0 ]]; then
                eval $(gpg-agent --daemon)
              fi
              if [ -f "${HOME}/.gpg-agent-info" ]; then
                  . "${HOME}/.gpg-agent-info"
                  export GPG_AGENT_INFO
                  export SSH_AUTH_SOCK
              fi
              ;;
  Linux)      # Add local bin directory to the path
              export PATH="${HOME}/.local/bin:${PATH}"
              ;;
  *)          echo "Unknwon Environment"
              ;;
esac
