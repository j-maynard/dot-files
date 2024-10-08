if [[ $(uname) == "Darwin" ]]; then
    gpg-agent > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
    eval $(gpg-agent --daemon)
    fi
    if [ -f "${HOME}/.gpg-agent-info" ]; then
        . "${HOME}/.gpg-agent-info"
        export GPG_AGENT_INFO
        export SSH_AUTH_SOCK
    fi
    if [ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]; then
        export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
    fi
fi