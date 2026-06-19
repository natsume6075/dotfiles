################################
###   ！！！編集禁止！！！   ###
################################
#
# zsh 設定(.zshenv を含む)は、~/.config/zsh 配下を SSoT とする。
#
# この ~/.zshenv は、ZDOTDIR 未設定の最初のシェルでのみ読み込まれる。
# ここでは、ZDOTDIR を立てて実体へ委譲するだけ。
# (ZDOTDIR 設定後の子シェルは $ZDOTDIR/.zshenv を直接読む)。
#
export ZDOTDIR=~/.config/zsh
[ -f "$ZDOTDIR/.zshenv" ] && source "$ZDOTDIR/.zshenv"
