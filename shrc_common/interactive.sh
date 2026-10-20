# bash / zsh 共通の、対話シェル用の設定 (POSIX sh 構文)。対話シェルでだけ読み込まれる。
# 読み込み元: ~/.zshrc (zsh)、~/.bashrc の対話時 (bash)。どちらも setup.sh が注入するブロックから呼ぶ。
# 流れ: 共通の設定 → シェル別の rc.zsh / rc.bash。シェル別の設定が、同名の共通の設定を上書きできる。
# 秘密情報・会社固有の設定は書かない (repo は public)。

# DOTFILES_DIR は env.sh が決める。まだ読まれていなければ読む。
[ -n "$DOTFILES_DIR" ] || . ~/.config/shrc_common/env.sh
[ -n "$DOTFILES_DIR" ] || return 0

# 共通の alias。zsh / bash のどちらでも同じ文法で書けるものだけを置く。
# 文法が異なるもの (zsh の alias -g など) は zsh/rc.zsh に置く。
alias adb='/mnt/c/ProgramData/chocolatey/bin/adb.exe'

# シェル別の対話設定
if [ -n "${ZSH_VERSION-}" ]; then
    . "$DOTFILES_DIR/zsh/rc.zsh"
elif [ -n "${BASH_VERSION-}" ]; then
    . "$DOTFILES_DIR/bash/rc.bash"
fi
