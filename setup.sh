#!/bin/bash
set -e -x

local DIR=${HOME}

get_dotfiles () {

    echo "(1/4): GETTING DOTFILES..."
    git clone https://github.com/asingh-io/dotfiles.git $DIR/dotfiles
    ln -s $DIR/dotfiles/.tmux.conf $DIR/.tmux.conf
    ln -s $DIR/dotfiles/.vimrc $DIR/.vimrc
    chown -R $USER:$USER $DIR/dotfiles $DIR/.vimrc $DIR/.tmux.conf

}

setup_vim () {

    echo "(2/4) SETTING UP VIM..."
    # Install black for formatting
    pip3 install black

    # Install vim plug for package management
    curl -fLo $DIR/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    chown -R $UER:ec2-user $DIR/.vim
    # Install packages
    vim +PlugInstall +qall

}

setup_tmux () {

    echo "(3/4) SETTING UP TMUX..."
    # Install tmux dependencies
    dnf -y install ncurses-devel
    dnf -y install libevent-devel
    dnf -y install htop

    dnf install tmux

    # Get the latest version
    # git clone https://github.com/tmux/tmux.git
    # cd tmux
    # sh autogen.sh
    # ./configure && make install
    # cd ..
}

setup_zsh () {

    echo "(4/4) SETTING UP ZSH..."
    dnf -y update && dnf -y install zsh
    # Install oh-my-zsh
    wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O $DIR/install.sh
    chown -R $USER:$USER $DIR/install.sh
    cd $DIR
    echo pwd
    install.sh
    # Change the default shell to zsh
    dnf -y install util-linux-user
    chsh -s /bin/zsh  $USER  
}

setup_powerline () {
	git clone --depth=1 git@github.com:romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	# set powerline10 K
	ZSH_THEME="powerlevel10k/powerlevel10k"

	echo "typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true" >> ~/.p10k.zsh
}

check_sudo() {
	if [ "$EUID" -ne 0 ]
	  then echo "Please run as root"
	  exit
	fi
}

get_dotfiles
setup_vim
setup_tmux
setup_zsh
