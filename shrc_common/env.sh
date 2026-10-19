# bash / zsh 共通の環境変数 (POSIX sh 構文)。
# ~/.zshenv と ~/.bashrc に setup.sh が注入するブロックから読み込まれる。
# 秘密情報・会社固有の設定は書かない (repo は public)。

# dotfiles のルート。setup.sh が張る ~/.config/shrc_common (symlink) の物理的な親ディレクトリ。
# パスを rc ファイルに焼き込まないので、repo を移しても setup.sh の再実行で symlink を張り直すだけでよい。
DOTFILES_DIR=$(cd -P ~/.config/shrc_common/.. 2>/dev/null && pwd -P)
export DOTFILES_DIR

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

# ホスト別の共通設定 (shrc_local/<ホスト名>.sh)。あれば読む。
# ホスト名は、WSL が設定する $NAME (Windows のコンピューター名) を優先し、無ければ uname -n。
_dotfiles_host=${NAME:-$(uname -n)}
[ -n "$DOTFILES_DIR" ] && [ -f "$DOTFILES_DIR/shrc_local/$_dotfiles_host.sh" ] && . "$DOTFILES_DIR/shrc_local/$_dotfiles_host.sh"
unset _dotfiles_host
