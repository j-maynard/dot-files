#!/bin/bash
if [[ $(uname) == "Linux" ]]; then
    # Clipboard handling
    alias setclip="xclip -selection c"
    alias getclip="xclip -selection c -o"
    alias pbcopy=setclip
    alias pbpaste=getclip
    #alias xclip="xclip -selection c"
    alias resetcam="sudo modprobe -r v4l2loopback && sudo modprobe v4l2loopback"
    alias camreset=resetcam

    # enable color support of ls and also add handy aliases
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        #alias ls='ls --color=auto'
        #alias dir='dir --color=auto'
        #alias vdir='vdir --color=auto'

        alias grep='grep --color=auto'
        alias fgrep='fgrep --color=auto'
        alias egrep='egrep --color=auto'
    fi
fi
