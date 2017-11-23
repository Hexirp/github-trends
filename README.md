# github-trends

[![Build Status](https://travis-ci.org/Hexirp/github-trends.svg?branch=master)](https://travis-ci.org/Hexirp/github-trends)

[GitHubが提供しているHaskellリポジトリのトレンド](https://github.com/trending/haskell)をスクレイピングし、slackに投稿します。このプログラムは[日本Haskellユーザーグループ](https://haskell.jp)のために作られました。

## 使用方法

stackを使用しています。

### ビルド

```bash
stack build
```

### 実行

```bash
./run.sh $TOKEN
```

TOKENは[古いタイプのトークン](https://api.slack.com/custom-integrations/legacy-tokens)です。

### TravisCI

このリポジトリの.travis.ymlは、`TOKEN=<token>`としてdeployingというブランチで実行すれば、自動でslackに投稿するように設定されています。
