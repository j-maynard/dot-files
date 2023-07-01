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
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
    sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
    sudo apt update && sudo apt install 1password-cli
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
    sudo apt-get update
    sudo apt install -y "git" "curl" "zsh" "build-essential" "htop" "tmux" "scdaemon" "pinentry-tty" "pinentry-curses" "gnupg2"

    if [[ $(uname -m) != "aarch64" ]]; then
        sudo add-apt-repository -y ppa:neovim-ppa/stable
        sudo apt install -y neovim
    else
        sudo apt-get install ninja-build \
            gettext libtool libtool-bin \
            autoconf automake cmake g++ \
            pkg-config unzip luajit
        git clone https://github.com/neovim/neovim.git /tmp/neovim
        cd /tmp/neovim
        git checkout stable
        sudo make install
    fi
}

linux_install() {
    if which lsb_release > /dev/null && lsb_release -d > /dev/null; then
        ubuntu_install_simple
        install_1password_cli
    fi
    install_posh
    install_yq
}

setup_directories() {
    mkdir -p ~/.local/bin
    mkdir -p ~/.config
    mkdir -p ~/Desktop
    mkdir -p ~/Developer/GitHub
    mkdir -p ~/Developer/GitLab-Personal
    mkdir -p ~/Developer/GitLab-Work
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

setup_neovim() {
    install_astronvim
}

# This is my historical vim setup
install_vimplug() {
    mkdir -p ~/.config/nvim
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    ln -s ~/.config/dot-files/vim/init.vim ~/.config/nvim/init.vim
    nvim -es -u init.vim -i NONE -c "PlugInstall" -c "qa"
}

install_astronvim() {
    git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
    if which nvim > /dev/null; then
        nvim +PackerSync
    fi
}

setup_directories
install_missing
setup_neovim
git clone https://gitlab.com/j-maynard/dot-files.git $TARGET_PATH

for i in ${DOT_FILES[@]}; do
    f=$(echo $i | cut -d '/' -f2)
    if [[ -f ~/.$f || -L $f ]]; then
        rm ~/.$f
    fi
    ln -s $TARGET_PATH/$i ~/.$f
done
