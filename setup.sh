#!/bin/sh
if test "$DROPBOX" = "" ; then
    echo "Dropboxへのパスを環境変数 DROPBOX に格納してください。"
    echo "bash: export DROPBOX=[pass]"
    exit
else
    ln -sfv $DROPBOX/dotfiles/.gitconfig ~/.gitconfig
    ln -sfv $DROPBOX/dotfiles/.zshrc ~/.zshrc
fi

