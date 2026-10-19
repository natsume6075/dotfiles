# bash / zsh 共通の環境変数 (POSIX sh 構文)。
# ~/.zshenv と ~/.bashrc に setup.sh が注入するブロックから読み込まれる。
# 秘密情報・会社固有の設定は書かない (repo は public)。

export EDITOR=nvim
export LANG=ja_JP.UTF-8

# Corporate proxy (~/.proxy_env に集約・repo には含めない。無ければ無視)
[ -f ~/.proxy_env ] && . ~/.proxy_env

# repo に入れられない環境変数は ~/.config/credentials/*.env (KEY=VALUE 形式・chmod 600) に置く。
# zsh はマッチしない glob をエラーにするため、関数内で null_glob を有効にする。
_dotfiles_load_env_dir() {
    [ -n "${ZSH_VERSION-}" ] && setopt local_options null_glob
    for _f in ~/.config/credentials/*.env; do
        [ -r "$_f" ] && { set -a; . "$_f"; set +a; }
    done
    unset _f
}
_dotfiles_load_env_dir
unset -f _dotfiles_load_env_dir

# ホスト別の共通設定 (shrc_local/<hostname>.sh)。あれば読む。
[ -f "$DOTFILES_DIR/shrc_local/$(uname -n).sh" ] && . "$DOTFILES_DIR/shrc_local/$(uname -n).sh"
