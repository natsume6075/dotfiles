#!/bin/sh
SCRIPT_DIR=$(cd $(dirname $0); pwd)
echo $SCRIPT_DIR

mkdir -p ~/.config/

ln -sfv $SCRIPT_DIR/.gitconfig ~/.gitconfig
ln -sfv $SCRIPT_DIR/.zshenv ~/.zshenv
ln -sfv $SCRIPT_DIR/.config/zsh ~/.config
ln -sfv $SCRIPT_DIR/.bashrc ~/.bashrc
ln -sfv $SCRIPT_DIR/.vimrc ~/.vimrc
ln -sfv $SCRIPT_DIR/.tmux.conf ~/.tmux.conf

