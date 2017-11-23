# github-trends

[![Build Status](https://travis-ci.org/Hexirp/github-trends.svg?branch=master)](https://travis-ci.org/Hexirp/github-trends)

[GitHubが提供しているHaskellリポジトリのトレンド](https://github.com/trending/haskell)をスクレイピングしてslackに投稿するプログラムです。[日本Haskellユーザーグループ](https://haskell.jp)のために作られました。

## 使用方法

`TOKEN=<token>`としてdeployingというブランチで実行すれば自動でslackに投稿するように.travis.ymlを設定しています。トークンは[古いタイプ](https://api.slack.com/custom-integrations/legacy-tokens)です。
