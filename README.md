# github-trends

[![Build Status](https://travis-ci.org/Hexirp/github-trends.svg?branch=master)](https://travis-ci.org/Hexirp/github-trends)

GitHubが提供しているHaskellリポジトリの[トレンド](https://github.com/trending/haskell)をスクレイピングしてslackに投稿するプログラムです。[日本Haskellユーザーグループ](https://haskell.jp)の[公式Slack](https://haskell-jp.slack.com/)でトレンドを見たくて作りました。

## 仕組み

Haskell製です。`GitHubTrends.hs`はトレンドのスクレイピング及び整形を行った後、引数に渡された[古いタイプのSlackトークン](https://api.slack.com/custom-integrations/legacy-tokens)を使って投稿します。見ての通り非推奨なのですが、新しいタイプのトークンはapp数を消費してしまうみたいなのでこの方法をあえて選択しています。

デプロイはTravis CIで行っています。デプロイの時にプログラムを実行するようにして、Cron機能を使って毎日ジョブを実行させています。古いSlackトークンはパスワードと同等に扱わなければならない代物なのでEncrypt機能を使って隠しています。
