#!/bin/sh
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
echo "$SCRIPT_DIR"

mkdir -p ~/.config/

# 設定ファイルへの symlink (home 直下の rc 系は symlink にしない。下の注入を参照)
ln -sfv "$SCRIPT_DIR/.gitconfig" ~/.gitconfig
ln -sfv "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf
ln -sfv "$SCRIPT_DIR/.vimrc" ~/.vimrc

# shrc_common / shrc_local は ~/.config からも辿れるようにする
ln -sfnv "$SCRIPT_DIR/shrc_common" ~/.config/shrc_common


# ~/.zshenv, ~/.zshrc, ~/.bashrc は symlink にせず、マシン所有の実ファイルとして残す。
# dotfiles を読み込むブロックだけを先頭に注入する (冪等。マーカーの内側だけ置き換える)。
# $1: 対象ファイル  $2: 注入するブロックの本文 (マーカー行は含めない)
inject() {
    target=$1
    body=$2
    [ -L "$target" ] && rm "$target"
    [ -e "$target" ] || : > "$target"
    tmp=$(mktemp)
    awk '/^# >>> dotfiles >>>$/{skip=1} !skip{print} /^# <<< dotfiles <<<$/{skip=0}' "$target" > "$tmp"
    {
        echo "# >>> dotfiles >>>"
        echo "# このブロックは dotfiles の setup.sh が注入したもの。再実行すると中身が置き換わるので、ブロック内は編集しないこと。"
        echo "# dotfiles を読み込む唯一のエントリポイント。dotfiles 由来の設定は、すべてこのブロックから読まれる。"
        echo "# ブロックの外は、このマシン専用の自由枠。インストーラーの追記や repo に入れられない設定を、自由に書いてよい。"
        echo "export DOTFILES_DIR=\"$SCRIPT_DIR\""
        printf '%s\n' "$body"
        echo "# <<< dotfiles <<<"
        cat "$tmp"
    } > "$target"
    rm "$tmp"
    echo "injected: $target"
}

inject ~/.zshenv '. "$DOTFILES_DIR/shrc_common/env.sh"'
inject ~/.zshrc '. "$DOTFILES_DIR/zsh/rc.zsh"'
inject ~/.bashrc '. "$DOTFILES_DIR/shrc_common/env.sh"
case $- in *i*) . "$DOTFILES_DIR/bash/rc.bash";; esac'

# 暫定: ZDOTDIR=~/.config/zsh を引き継いだ既存プロセス (tmux/herdr など) の zsh 向けの shim。
# 新しい zsh が ZDOTDIR を捨てて、home の ~/.zshenv / ~/.zshrc を読むようにする。
# すべてのプロセスを再起動したあとなら、このブロックと ~/.config/zsh は削除してよい。
[ -L ~/.config/zsh ] && rm ~/.config/zsh
mkdir -p ~/.config/zsh
printf '%s\n' 'unset ZDOTDIR' '[ -f ~/.zshenv ] && . ~/.zshenv' > ~/.config/zsh/.zshenv
