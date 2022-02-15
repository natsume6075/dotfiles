#!/bin/sh
SCRIPT_DIR=$(cd $(dirname $0); pwd)
echo $SCRIPT_DIR

ln -sfv $SCRIPT_DIR/.gitconfig ~/.gitconfig
ln -sfv $SCRIPT_DIR/.zshrc ~/.zshrc
ln -sfv $SCRIPT_DIR/.vimrc ~/.vimrc

