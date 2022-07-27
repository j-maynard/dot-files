#!/bin/bash
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
TARGET_PATH=`~/.config/dotfiles`
ARCH=`uname -m`

DOT_FILES=(
    "zsh/zsh_plugins.txt" "zsh/zprofile" "zsh/zshrc" "zsh/zshenv" 
    "tmux/tmux.local" "git/gitconfig"  "git/gitignore_global"
    "bash_profile"
)

# Define colors and styles
normal="\033[0m"
bold="\033[1m"
green="\e[32m"
red="\e[31m"
yellow="\e[93m"

version() {
    echo "Dot Files Setup Script Version 1.1"
    echo "(c) Jamie Maynard 2022"
}

check_requirements() {
    MSG="${red}Your system doesn't meet the following requirements:\n"

    which git > /dev/null
    if [ "$?" != 0 ]; then
        MSG="${MSG}\t* ${bold}Git${normal}${red} is not installed\n"
        FAIL=true
    fi

    which wget > /dev/null
    if [ "$?" != 0 ]; then
        MSG="${MSG}\t* ${bold}wget${normal}${red} is not installed\n"
        FAIL=true
    fi

    if [ FAIL == 'true' ]; then
        echo "${MSG}${normal}"
        echo "You'll need to fix the requirements before running this script"
        if [ $SHOW_ONLY == 'true' ]; then
            exit 1
        else
            exit 0
        fi
    fi
}

install_yq() {
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        arm)        ARCH=arm
                    ;;
        armf)       ARCH=arm
                    ;;
        arm64)      ARCH=arm64
                    ;;
        aarch64)    ARCH=arm64
                    ;;
        *)          echo "${red}Can't identify Arch to match to an LSD download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    wget -q -O ~/.local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}
    chmod +x ~/.local/bin/yq
}

install_posh() {
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        arm)        ARCH=arm
                    ;;
        armf)       ARCH=arm
                    ;;
        arm64)      ARCH=arm64
                    ;;
        aarch64)    ARCH=arm64
                    ;;
        *)          echo "${red}Can't identify Arch to match to an LSD download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    wget -q -O ~/.local/bin/oh-my-posh https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${ARCH}
    chmod +x ~/.local/bin/oh-my-posh
}

install_lsd() {
    LSDVER=$(wget -q -O - https://github.com/Peltoche/lsd/tags.atom | yq -p=xml '.feed.entry[0].title')
    case $(uname -m) in
        x86_64)     ARCH=x86_64
                    ;;
        arm64)      ARCH=aarch64
                    ;;
        aarch64)    ARCH=aarch64
                    ;;
        *)          echo "${red}Can't identify Arch to match to an LSD download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    echo "Installing the latest version of LSD -> version: ${LSDVER}..."
    wget -q -O /tmp/lsd-${LSDVER}-${ARCH}-unknown-linux-gnu.tar.gz "https://github.com/Peltoche/lsd/releases/download/${LSDVER}/lsd-${LSDVER}-${ARCH}-unknown-linux-gnu.tar.gz"
    if [ ! -f "/tmp/lsd-${LSDVER}-${ARCH}-unknown-linux-gnu.tar.gz" ]; then
        echo "${red}Failed to download go... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    tar zxf /tmp/lsd-${LSDVER}-${ARCH}-unknown-linux-gnu.tar.gz -C /tmp
    mv /tmp/lsd-${LSDVER}-${ARCH}-unknown-linux-gnu/lsd ~/.local/bin
    
    if [ $? == 0 ]; then
        return 0
    else
        echo "Failed to install ls replacement lsd"
        return 1
    fi
}

install_bat() {
    BATVER=$(wget -q -O - https://github.com/sharkdp/bat/releases.atom | yq -p=xml '.feed.entry[0].title')
    case $(uname -m) in
        x86_64)     ARCH=x86_64
                    TARGET=bat-${BATVER}-${ARCH}-unknown-linux-gnu
                    ;;
        arm64)      ARCH=aarch64
                    TARGET=bat-${BATVER}-${ARCH}-unknown-linux-gnu
                    ;;
        aarch64)    ARCH=aarch64
                    TARGET=bat-${BATVER}-${ARCH}-unknown-linux-gnu
                    ;;
        armf)       ARCG=arm
                    TARGET=bat-${BATVER}-${ARCH}-unknown-linux-gnueabihf
                    ;;
        *)          echo "${red}Can't identify Arch to match to an bat download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of bat -> version: ${BATVER}..."

    wget -q -O /tmp/$TARGET.tar.gz "https://github.com/sharkdp/bat/releases/download/${BATVER}/${TARGET}.tar.gz"
    if [ ! -f "/tmp/$TARGET.tar.gz" ]; then
        show_msg "${red}Failed to download bat... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    tar -zxf /tmp/$TARGET.tar.gz -C /tmp
    mv /tmp/$TARGET/bat ~/.local/bin/bat
    if [ $? == 0 ]; then
        return 0
    else
        show_msg "Failed to install bat the cat clone with wings"
        return 1
    fi
}

install_1password_cli() {
    OPVER=$(wget -q -O - https://app-updates.agilebits.com/product_history/CLI2 | sed -n "/<h3>/,/<\h3>/p" | head -n2 | tr -d '\n' |  sed 's/$/<\/h3>/' | yq -p=xml '.h3')
    case $(uname -m) in
        x86_64)     ARCH=amd64
                    ;;
        arm64)      ARCH=arm64
                    ;;
        aarch64)    ARCH=arm64
                    ;;
        armf)       ARCG=arm
                    ;;
        *)          echo "${red}Can't identify Arch to match to an 1password cli download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
                    return 0
    esac
    show_msg "Installing the latest version of 1password cli -> version: ${OPVER}..."

    wget -q -O /tmp/op_linux_${ARCH}_v${OPVER}.zip "https://cache.agilebits.com/dist/1P/op2/pkg/v${OPVER}/op_linux_${ARCH}_v${OPVER}.zip"
    if [ ! -f "/tmp/op_linux_${ARCH}_v${OPVER}.zip" ]; then
        show_msg "${red}Failed to download 1password cli... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    unzip /tmp/op_linux_${ARCH}_v${OPVER}.zip -d /tmp
    mv /tmp/op ~/.local/bin/op
    if [ $? == 0 ]; then
        return 0
    else
        show_msg "Failed to install bat the cat clone with wings"
        return 1
    fi
}

install_antibody() {
	if ! which antibody > /dev/null; then
	    show_msg "Installing antibody..."
	    wget -q -O - git.io/antibody | sh -s - -b ~/.local/bin
	fi
}

install_fzf() {
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin
}

brew_install() {
    if which brew > /dev/null; then
        brew install lsd antibody oh-my-posh bat yq fzf 1password-cli
        $(brew --prefix)/opt/fzf/install
    fi
}

linux_install() {
    install_posh
    install_antibody
    install_yq
    install_lsd
    install_bat
    install_fzf
    install_1password_cli
}


install_missing() {
    mkdir -p ~/.local/bin
    
    if [[ $INSTALL == "false" ]]; then
        return 0
    fi

    case $(uname) in
        Linux)      linux_install
                    ;;
        Darwin)     brew_install
                    ;;
        *)          echo "${red}Unknown Operating System... ${normal}${green}Skipping Installs...${normal}"
                    return 0
    esac
}

if [ -d zsh ]; then
    # Assume we have a complete directory
else
    git clone 
fi