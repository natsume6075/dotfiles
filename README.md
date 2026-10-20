# Linux 環境向け dotfiles 集

## 導入 - 自動化スクリプト setup.sh

- setup.sh によって導入は自動化されている。
- このリポジトリを任意の場所に配置し、setup.sh を呼べば良い。
- このリポジトリは単体でも導入できるし、以下のリポジトリのコンポーネントとしても動作する。
https://github.com/natsume6075/setup/tree/master/linux 

## ディレクトリ構成

setup.sh を実行した後のディレクトリ構成。

``` sh
├── .bashrc      (実ファイル。setup.sh が dotfiles の読み込みブロックを先頭に注入)
├── .config
│   └── shrc_common@
├── .gitconfig@
├── .tmux.conf@
├── .vimrc@
├── .zshenv      (実ファイル。同上)
└── .zshrc       (実ファイル。同上)
```

## 読み込みの仕組み

- `.bashrc` / `.zshenv` / `.zshrc` は symlink にしない。マシン所有の実ファイルとして残し、`setup.sh` が `# >>> dotfiles >>>` ～ `# <<< dotfiles <<<` のブロックだけを先頭に注入する(再実行しても 1 個のまま)。
  - このブロックが dotfiles の唯一のエントリポイント。ブロックの外は、マシン専用の自由枠(インストーラーの追記もここに入る)。
- 読み込みは、対話・非対話の「段階」ごとに common の 2 ファイルへ分ける。ブロックは段階の入口だけを持ち、振り分けは repo 側のファイルが行う。
  - すべてのシェル(非対話を含む): `.zshenv` / `.bashrc` → `shrc_common/env.sh` → `shrc_local/<ホスト名>.sh`
  - 対話シェルのみ: `.zshrc`(zsh) / `.bashrc` の対話時(bash) → `shrc_common/interactive.sh` → 共通の alias → シェル別の `zsh/rc.zsh` / `bash/rc.bash`
  - シェル別の設定は、共通のあとに読まれるので、同名の共通設定を上書きできる。zsh と bash で文法が異なる alias(`alias -g` など)は、それぞれの `rc.*` に置く。
- ホスト名は、WSL が設定する `$NAME`(Windows のコンピューター名)を優先し、無ければ `uname -n`。
- dotfiles の場所(`DOTFILES_DIR`)は、rc ファイルに焼き込まない。`setup.sh` が張る `~/.config/shrc_common`(symlink)の物理的な親ディレクトリから、`env.sh` が求める。repo を移したら、`setup.sh` を再実行して symlink を張り直す。`setup.sh` は、どのディレクトリから、どの呼び方(相対パス・symlink 経由・他のリポジトリからの呼び出し)で実行してもよい。ただし source はしない。
- `ZDOTDIR` は使わない。
- repo に入れられない環境変数は `~/.config/credentials/*.env`(`KEY=VALUE` 形式・chmod 600)に置く。`env.sh` が全部読む。

## 方針

- home 直下の rc 系ファイルは、dotfiles の entrypoint を注入するだけにして、メインの設定は repo に置く。
- でかい設定ファイルは、リポジトリを分ける。
  - nvim とか。
- Linux/Mac で差分が生じてしまうような機能も、リポジトリを分ける。

## ネットワーク設定

- プロキシ設定はリポジトリに含めない。`~/.proxy_env` に集約し、`shrc_common/env.sh` がそれを source する。`~/.proxy_env` が存在しない場合は無視されるため、非プロキシ環境でもそのまま動作する。
- プロキシ環境下でのセットアップは [setup/linux](https://github.com/natsume6075/setup/tree/master/linux) を参照。
