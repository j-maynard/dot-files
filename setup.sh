#!/bin/bash
SCRIPT=`realpath -s $0`
SCRIPTPATH=`dirname $SCRIPT`
TARGET_PATH=~/.config/dot-files
ARCH=`uname -m`

DOT_FILES=(
    "zsh/zsh_plugins.txt" "zsh/zprofile" "zsh/zshrc" "zsh/zshenv" 
    "tmux/tmux.conf.local" "git/gitconfig"  "git/gitignore_global"
    "bash/bashrc"
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

    if which git > /dev/null; then
        MSG="${MSG}\t* ${bold}Git${normal}${red} is not installed\n"
        FAIL=true
    fi

    which wget > /dev/null
    if [[ "$?" != 0 && $(uname) == "Linux" ]]; then
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
        *)          echo "${red}Can't identify Arch to match to an yq download.  Arch = $(uname -m)... ${normal}${green}Skipping...${normal}"
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

install_rust() {
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source ~/.cargo/env
    cargo install bat lsd htmlq
}

install_1password_cli() {
    OPVER=$(wget -q -O - https://app-updates.agilebits.com/product_history/CLI2 |htmlq  h3 -r span | yq -p=xml '.h3' | head -n1 | tr -d " -")
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
    echo "Installing the latest version of 1password cli -> version: ${OPVER}..."

    wget -q -O /tmp/op_linux_${ARCH}_v${OPVER}.zip "https://cache.agilebits.com/dist/1P/op2/pkg/v${OPVER}/op_linux_${ARCH}_v${OPVER}.zip"
    if [ ! -f "/tmp/op_linux_${ARCH}_v${OPVER}.zip" ]; then
        echo "${red}Failed to download 1password cli... ${normal}${green}Skipping install...${normal}"
        return 1
    fi
    unzip -qq /tmp/op_linux_${ARCH}_v${OPVER}.zip -d /tmp
    mv /tmp/op ~/.local/bin/op
    if [ $? == 0 ]; then
        rm -r /tmp/op*
        return 0
    else
        echo "Failed to install 1password CLI.  This function is not stable."
        return 1
    fi
}

install_antibody() {
	if ! which antibody > /dev/null; then
	    echo "Installing antibody..."
	    wget -q -O - git.io/antibody | sh -s - -b ~/.local/bin
	fi
}

install_fzf() {
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin
}

brew_install() {
    if ! which brew > /dev/null; then 
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install wget oh-my-posh yq fzf 1password-cli neovim gnupg2 tmux htop
    $(brew --prefix)/opt/fzf/install
}

ubuntu_install_simple() {
    sudo add-apt-repository -y ppa:git-core/ppa
    sudo add-apt-repository -y ppa:neovim-ppa/stable
    sudo apt-get update
    sudo apt install -y "git" "curl" "zsh" "build-essential" "htop" "tmux" "neovim" "scdaemon" "pinentry-tty" "pinentry-curses" "gnupg2"
}

linux_install() {
    if which lsb_release > /dev/null && lsb_release -d > /dev/null; then
        ubuntu_install_simple
    fi
    install_posh
    install_yq
    install_1password_cli
}

setup_directories() {
    mkdir -p ~/.local/bin
    mkdir -p ~/.config
    mkdir -p ~/Desktop
    mkdir -p ~/Development/GitHub
    mkdir -p ~/Development/GitLab
    mkdir -p ~/Documents
    mkdir -p ~/Pictures
    mkdir -p ~/Downloads
    export PATH=~/.local/bin:$PATH
}

install_missing() {
    if [[ $INSTALL == "false" ]]; then
        return 0
    fi

    install_rust
    install_fzf
    install_antibody
    
    case $(uname) in
        Linux)      linux_install
                    ;;
        Darwin)     brew_install
                    ;;
        *)          echo "${red}Unknown Operating System... ${normal}${green}Skipping Installs...${normal}"
                    return 0
    esac
}

install_astronvim() {
    git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
    if which nvim > /dev/null; then
        nvim +PackerSync
    fi
}

setup_directories
install_missing
install_astronvim
git clone https://gitlab.com/j-maynard/dot-files.git $TARGET_PATH

for i in ${DOT_FILES[@]}; do
    f=$(echo $i | cut -d '/' -f2)
    if [[ -f ~/.$f || -L $f ]]; then
        rm ~/.$f
    fi
    ln -s $TARGET_PATH/$i ~/.$f
done