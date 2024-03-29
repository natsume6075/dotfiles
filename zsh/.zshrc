# 不適切なロケール設定を修復する
eval $(/usr/bin/locale-check C.UTF-8)

if command -v nvim >/dev/null; then
    alias vim='nvim'
fi

# Ctrl+Dでログアウトしてしまうことを防ぐ
setopt IGNOREEOF

# PATH
export PATH="$HOME/bin:$PATH"
export PATH="//Applications/gnuplot.app:$PATH"
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/Cellar/gcc/9.2.0_3/bin/:$PATH

# 色を使用
autoload -Uz colors
colors

# プロンプト
autoload -U promptinit; promptinit
# prompt pure

# 補完
autoload -Uz compinit
compinit

# emacsキーバインド
bindkey -e

# 他のターミナルとヒストリーを共有
setopt share_history

# ヒストリーに重複を表示しない
setopt histignorealldups

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# cdコマンドを省略して、ディレクトリ名のみの入力で移動
setopt auto_cd

# 自動でpushdを実行
setopt auto_pushd

# pushdから重複を削除
setopt pushd_ignore_dups

# コマンドミスを修正
setopt correct

# グローバルエイリアス
alias -g L='| less'
alias -g H='| head'
alias -g G='| grep'
alias -g GI='| grep -ri'

# エイリアス
alias lst='ls -ltr --color=auto'
alias l='ls -ltr --color=auto'
alias la='ls -la --color=auto'
alias ll='ls -l --color=auto'
alias c='cdr'

# historyに日付を表示
alias h='fc -lt '%F %T' 1'
alias cp='cp -i'
alias rm='rm -i'
alias mkdir='mkdir -p'
alias ..='c ../'
alias back='pushd'
alias diff='diff -U1'

# backspace,deleteキーを使えるように
stty erase ^H
bindkey "^[[3~" delete-char

# cdの後にlsを実行
chpwd() { ls -ltr --color=auto }

# どこからでも参照できるディレクトリパス
cdpath=(~)

# 区切り文字の設定
autoload -Uz select-word-style
select-word-style default
    zstyle ':zle:*' word-chars "_-./;@"
    zstyle ':zle:*' word-style unspecified

# Ctrl+sのロック, Ctrl+qのロック解除を無効にする
setopt no_flow_control

# 補完後、メニュー選択モードになり左右キーで移動が出来る
zstyle ':completion:*:default' menu select=2

# 補完で大文字にもマッチ
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Ctrl+rでヒストリーのインクリメンタルサーチ、Ctrl+sで逆順
bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward

# TODO Up Dwon にマッピングされてない
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
# bindkey "^[[A" history-beginning-search-backward-end
# bind '"\e[B": history-search-forward'
# bind '"\e[A": history-search-backward'
bindkey "\e[A" history-beginning-search-backward
bindkey "^b" history-beginning-search-forward-end
bindkey "^[[B" history-beginning-search-forward-end

# cdrコマンドを有効 ログアウトしても有効なディレクトリ履歴
# cdr タブでリストを表示
autoload -Uz add-zsh-hook
autoload -Uz chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs
# cdrコマンドで履歴にないディレクトリにも移動可能に
zstyle ":chpwd:*" recent-dirs-default true

# 複数ファイルのmv 例　zmv *.txt *.txt.bk
autoload -Uz zmv
alias zmv='noglob zmv -W'

# mkdirとcdを同時実行
function mkcd() {
    if [[ -d $1 ]]; then
        echo "$1 already exists!"
        cd $1
    else
        mkdir -p $1 && cd $1
    fi
}

# git設定
# RPROMPT="%{${fg[blue]}%}[%~]%{${reset_color}%}"
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }
RPROMPT=$RPROMPT'${vcs_info_msg_0_}'

# tmux に入っていない => tmux 起動して main セッションに入る、なければ作る。
tmux a -t main
set tmux_ret $status
if [[ $status == 0 ]]; then
    tmux new-session -s main
fi

# プロンプトを2行で表示、時刻を表示
# PROMPT="%(?.%{${fg[green]}%}.%{${fg[red]}%})%n${reset_color}@${fg[blue]}%m${reset_color}(%*%) %~
# %# "

# SSH接続している場合のみ、ホスト名・ユーザー名を表示する。
set_prompt() {
    if [ -n "$SSH_CONNECTION" ]; then
        PROMPT="
%{$fg[magenta]%}%n@%m%{$reset_color%}:${fg[cyan]}%~
%(?.%{${fg[magenta]}%}.%{${fg[red]}%})%# ${reset_color}"
    else
        PROMPT="
${fg[cyan]}%~
%(?.%{${fg[magenta]}%}.%{${fg[red]}%})%# ${reset_color}"
    fi
}
set_prompt

source $ZDOTDIR/.zshrc_local_entrypoint

