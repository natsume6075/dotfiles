## ディレクトリ構成

setup.sh を実行した後のディレクトリ構成。

``` sh
├── .bashrc@
├── .config
│   └── zsh@
├── .gitconfig@
├── .tmux.conf@
├── .vimrc@
└── .zshenv@
```

## 方針

- home 直下に置く設定ファイルは、1機能につき1つにしたい。2つ以上ある場合は、最小限の entrypoint のみを home 直下に置いて、メインの設定を .config/hoge に置く。
- でかい設定ファイルは、リポジトリを分ける。
  - nvim とか。
- Linux/Mac で差分が生じてしまうような機能も、リポジトリを分ける。

## ネットワーク設定（社内プロキシ）

- プロキシ設定はリポジトリに含めない。`~/.proxy_env` に集約し、`.bashrc` / `.zshenv` はそれを source するだけにする。`~/.proxy_env` が存在しない場合は無視されるため、非プロキシ環境でもそのまま動作する。
- プロキシ環境下でのセットアップは [setup/linux](https://github.com/natsume6075/setup/tree/master/linux) を参照。

