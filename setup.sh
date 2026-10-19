#!/bin/sh
# 実行すること (source しない)。どのディレクトリから、どの呼び方 (相対パス・symlink 経由・他の
# リポジトリからの呼び出し) で実行しても、この repo の実体を指す。
SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd -P) || exit 1
echo "$SCRIPT_DIR"

mkdir -p ~/.config/

# 設定ファイルへの symlink (home 直下の rc 系は symlink にしない。下の注入を参照)
ln -sfv "$SCRIPT_DIR/.gitconfig" ~/.gitconfig
ln -sfv "$SCRIPT_DIR/.tmux.conf" ~/.tmux.conf
ln -sfv "$SCRIPT_DIR/.vimrc" ~/.vimrc

# dotfiles の場所を示す唯一の固定点。rc ファイルにパスを焼き込まず、env.sh がここから
# DOTFILES_DIR を求める。repo を移したら、setup.sh を再実行して張り直す。
if [ -e ~/.config/shrc_common ] && [ ! -L ~/.config/shrc_common ]; then
    echo "error: ~/.config/shrc_common が symlink ではない。退避してから再実行すること" >&2
    exit 1
fi
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
        printf '%s\n' "$body"
        echo "# <<< dotfiles <<<"
        cat "$tmp"
    } > "$target"
    rm "$tmp"
    echo "injected: $target"
}

inject ~/.zshenv '. ~/.config/shrc_common/env.sh'
inject ~/.zshrc '[ -n "$DOTFILES_DIR" ] || . ~/.config/shrc_common/env.sh
. "$DOTFILES_DIR/zsh/rc.zsh"'
inject ~/.bashrc '. ~/.config/shrc_common/env.sh
case $- in *i*) . "$DOTFILES_DIR/bash/rc.bash";; esac'

# 暫定: ZDOTDIR=~/.config/zsh を引き継いだ既存プロセス (tmux/herdr など) の zsh 向けの shim。
# 新しい zsh が ZDOTDIR を捨てて、home の ~/.zshenv / ~/.zshrc を読むようにする。
# すべてのプロセスを再起動したあとなら、このブロックと ~/.config/zsh は削除してよい。
[ -L ~/.config/zsh ] && rm ~/.config/zsh
mkdir -p ~/.config/zsh
printf '%s\n' 'unset ZDOTDIR' '[ -f ~/.zshenv ] && . ~/.zshenv' > ~/.config/zsh/.zshenv
