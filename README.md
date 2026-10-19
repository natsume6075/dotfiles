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
- 読み込みの流れ:
  - 環境変数: `.zshenv` / `.bashrc` → `shrc_common/env.sh` → `shrc_local/<hostname>.sh`
  - zsh の対話設定: `.zshrc` → `zsh/rc.zsh`
  - bash の対話設定: `.bashrc` → `bash/rc.bash`(対話シェルのときのみ)
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
