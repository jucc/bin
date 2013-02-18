#!/bin/bash
#
# File: setup.sh
# Description: setup dotfiles and custom scripts
#

PREFIX="$HOME/bin/dotfiles"

task_done() {
    echo -e "\e[1;32mDone!\e[0m"
}

set_link() {
    local SRC="$1"
    local TGT="$2"

    if [ -s "$SRC" ]; then
        echo -e "\e[0;34m $SRC already exists. \e[0m"
        return 1
    fi
    ln -s $TGT $SRC && echo -e "\e[0;32m $SRC configured! \e[0m"
}

set_ssh() {
    echo -e "\e[1;33m[ssh]\e[0m"
    set_link "$HOME/.ssh/config" "$PREFIX/ssh/config" && task_done
}

set_vim() {
    echo -e "\e[1;33m[vim]\e[0m"
    set_link "$HOME/.vimrc" "$PREFIX/vim/vimrc" && task_done
}

set_git() {
    echo -e "\e[1;33m[git]\e[0m"
    set_link "$HOME/.gitconfig" "$PREFIX/git/gitconfig" && task_done
}

add_line() {
    local LINE="$1"
    local FILE="$2"
        
    if [ ! -f "$FILE" ]; then
        echo -e "\e[0;34mFile: $FILE does not exist. \e[0m"
        return 1        
    fi
    grep "$LINE" "$FILE"
    if [ ! "$?" = 0 ]; then
        echo "$LINE" >> "$FILE"
        if [ "$?" = 0 ]; then
            echo -e "\e[0;32mLine: \"$LINE\" added to $FILE!\e[0m"
        else
            return 1
        fi
    else
        echo -e "\e[0;34mLine: \"$LINE\" already exists in $FILE. \e[0m"
    fi
}
    
set_bashmarks() {
    echo -e "\e[1;33m[bashmarks]\e[0m"
    git clone git://github.com/huyng/bashmarks.git /tmp/bashmarks
    if [ ! "$?" = 0 ]; then
        echo -e "\e[1;31mProblem during repository cloning.\e[0m"
        return 1
    fi

    cd /tmp/bashmarks && 
        make install >/dev/null &&
        add_line ". ~/.local/bin/bashmarks.sh" "$PREFIX/bashrc" &&
        cd - &&
        rm -rf /tmp/bashmarks && 
        task_done
}

set_bashrc() {
    echo -e "\e[1;33m[bashrc]\e[0m"
    touch ~/.bashrc && 
        add_line ". $PREFIX/bashrc" ~/.bashrc &&
        task_done
}

print_help() {
    echo "Usage: $(basename $0) [OPTIONS]

OPTIONS:
    -a, --all
    -r, --bashrc
    -v, --vim
    -s, --ssh
    -g, --git
    -k, --bashmarks
    -h, --help"
}

while [ -n "$1" ]
do
    case $1 in
        -r | --bashrc) set_bashrc ;;
        -s | --ssh) set_ssh ;;
        -v | --vim) set_vim ;;
        -g | --git) set_git ;;
        -k | --bashmarks) set_bashmarks ;;
        -a | --all)
            set_bashrc
            set_ssh
            set_vim
            set_git
            set_bashmarks
            ;;
        -h | --help) print_help;;
        *) echo "Invalid option: $1" && print_help
    esac
    shift
done
