#!/bin/bash
set -e -x

DIR=${HOME}

get_dotfiles () {
    echo "(1/4): GETTING DOTFILES..."
    rm -rf $DIR/dotfiles
    git clone https://github.com/AnandSingh/dotfiles.git $DIR/dotfiles
    rm -f $DIR/.tmux.conf $DIR/.vimrc
    ln -s $DIR/dotfiles/.tmux.conf $DIR/.tmux.conf
    ln -s $DIR/dotfiles/.vimrc $DIR/.vimrc
}

setup_vim () {

    echo "(2/4) SETTING UP VIM..."
    # Install black for formatting
    sudo dnf -y install vim python3-pip
    pip3 install black

    # Install vim plug for package management
    curl -fLo $DIR/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    # Install packages
    vim +PlugInstall +qall

}

setup_tmux () {

    echo "(3/4) SETTING UP TMUX..."
    # Install tmux dependencies
    sudo dnf -y install ncurses-devel
    sudo dnf -y install libevent-devel

    # Get the latest version
    git clone https://github.com/tmux/tmux.git
    cd tmux
    sh autogen.sh
    ./configure && make install
    cd ..
    # Install htop
    sudo dnf -y install htop

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

setup_zsh () {

    echo "(4/4) SETTING UP ZSH..."
    sudo dnf -y update && sudo dnf -y install zsh
    # Install oh-my-zsh
    wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O $DIR/install.sh
    cd $DIR
    echo pwd
    chmod +x ./install.sh
    ./install.sh

    # Setting zsh plugin 
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    # Change the default shell to zsh
    sudo dnf -y install util-linux-user
    chsh -s /bin/zsh ${USER} 
}

setup_powerlevel10k() {
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    rm -r ~/.zshrc
    ln -s $DIR/dotfiles/.zshrc $DIR/.zshrc
}

get_dotfiles
setup_vim
setup_tmux
setup_zsh
setup_powerlevel10k
