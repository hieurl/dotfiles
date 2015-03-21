#!/usr/bin/env bash
set -e

here="$(dirname "$0")"
here="$(cd "$here"; pwd)"

(cd $here; git submodule init)
(cd $here; git submodule update)

mkln () {
    for file in "$here"/"$1"*; do
        name="$(basename "$file")"
        if [[ !( " bin config initialize.bash oh-my-zsh-custom readme.md " =~ " $name " ) ]]; then
            if [[ $2 == 't' ]]; then
                if [[ -e "$HOME/.$1$name" ]]; then
                    rm -rv "$HOME/.$1$name"
                fi
                if [[ `uname` == 'Linux' ]]; then
                    ln -sfv $file "$HOME/.$1$name"
                elif [[ `uname` == 'Darwin' ]]; then
                    ln -sfhv $file "$HOME/.$1$name"
                else
                    echo "UNSUPPORTED PLATFORM!!!!!!!!!!"
                    exit 1
                fi
            else
                if [[ -e "$HOME/.$1$name" ]]; then
                    echo "  `dirname $HOME/.$1$name`/`basename\
                    $HOME/.$1$name`"
                fi
            fi
        fi
    done
}

chkln () {
    for file in "$here/$1"*; do
        name="$(basename "$file")"
        if [[ -e "$HOME/$1$name" ]]; then
            echo "  `dirname $HOME/$1$name`/`basename\
            $HOME/$1$name`"
        fi
    done
}

echo "Conflicting dotfiles in $HOME:"
mkln '' f
mkln 'config/' f
chkln 'bin/'
echo -n "Type Y/y to overwrite those files: "
read -n 1 c
echo ''
if [[ $c == 'Y' ]] || [[ $c == 'y' ]]; then
    if [[ ! -d "$HOME/.config" ]]; then
        echo "Creating ~/.config"
        mkdir "$HOME/.config"
    fi

    if [[ ! -d "$HOME/bin" ]]; then
        echo "Creating ~/bin"
        mkdir "$HOME/bin"
    fi

    mkln '' t
    mkln 'config/' t

    if [[ `uname` == 'Linux' ]]; then
        find "$here/bin" -maxdepth 1 -mindepth 1 -type f -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/bin/"
        find "$here/oh-my-zsh-custom/custom" -maxdepth 1 -mindepth 1 -type f -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/custom/"
        find "$here/oh-my-zsh-custom/themes" -maxdepth 1 -mindepth 1 -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/themes/"
        find "$here/oh-my-zsh-custom/custom/plugins/" -maxdepth 1 -mindepth 1 -print0 | xargs -0 -L 1 -I % ln -sfv % "$HOME/.oh-my-zsh/custom/plugins/"
    elif [[ `uname` == 'Darwin' ]]; then
        find "$here/bin" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/bin"
        find "$here/oh-my-zsh-custom/custom" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/custom/"
        find "$here/oh-my-zsh-custom/themes" -type f -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/themes/"
        find "$here/oh-my-zsh-custom/custom/plugins" -depth 1 -print0 | xargs -0 -L 1 -I % ln -sfhv % "$HOME/.oh-my-zsh/custom/plugins/"
    fi
fi

if [[ ! -d "$HOME/.vimbackup" ]]; then
    echo "Creating ~/.vimbackup"
    mkdir "$HOME/.vimbackup"
fi

if [[ ! -d "$HOME/.fonts" ]]; then
    echo "Creating ~/.fonts"
    mkdir "$HOME/.fonts"
fi

if grep -c debian /etc/*release* > /dev/null; then
    echo 'Installing stuff ...'
    sudo apt-get install aptitude
    sudo aptitude install python-pip tmux git zsh
    echo 'Installing powerline'
    pip install --user git+git://github.com/Lokaltog/powerline
    find $HOME -iregex '.*tmux/powerline.conf' 2> /dev/null -print0 | xargs -0 -I % ln -sfv % $HOME/.powerline-tmux.conf
    echo 'Installing powerline-patched-font'
    git clone https://github.com/Lokaltog/powerline-fonts $HOME/powerline-font-82374846
    find $HOME/powerline-font-82374846 -regextype posix-extended -iregex '.*\.(otf|ttf)' -print0 | xargs -0 -I % mv -v % $HOME/.fonts/
    rm -rfv $HOME/powerline-font-82374846
    fc-cache -vf $HOME/.fonts/
    chsh -s `which zsh`
fi

