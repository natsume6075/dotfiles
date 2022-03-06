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

