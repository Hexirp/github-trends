# github-trends

[![Build Status](https://travis-ci.org/Hexirp/github-trends.svg?branch=master)](https://travis-ci.org/Hexirp/github-trends)

GitHub が提供している Haskell リポジトリの[トレンド](https://github.com/trending/haskell)をスクレイピングして slack に投稿するプログラムです。
[日本 Haskell ユーザーグループ](https://haskell.jp)の[公式 Slack](https://haskell-jp.slack.com/) でトレンドを見たくて作りました。
もちろん、Haskell製です！

## 仕組み

トレンドのスクレイピング及び整形を行った後、引数に渡された[古いタイプの Slack トークン](https://api.slack.com/custom-integrations/legacy-tokens)を使って投稿します。
見ての通り非推奨なのですが、新しいタイプのトークンはapp数を消費してしまうみたいなのでこの方法をあえて選択しています。

デプロイは Travis CI で行っています。
デプロイの時にプログラムを実行するようにして、Cron 機能を使って毎日ジョブを実行させています。
古い Slack トークンはパスワードと同等に扱わなければならない代物なので Encrypt 機能を使って隠しています。

### 形式

```
(新しいトレンドの番号付きリスト)

(全てのトレンドの番号付きリスト)
```

### 内部

[http-conduit](https://hackage.haskell.org/package/http-conduit) ライブラリを使用して[週間でのトレンドのページ](https://github.com/trending/haskell?since=weekly)を取得します。
その後、[html-conduit](https://hackage.haskell.org/package/html-conduit) ライブラリを使用してXMLデータとして読み込み、[xml-conduit](https://hackage.haskell.org/package/xml-conduit) ライブラリを使用してリポジトリ名をリストの形で取り出します。
そのリポジトリのリストを、（ Slack の表記での）リストに整えて、メッセージを構築して [http-conduit](https://hackage.haskell.org/package/http-conduit) をまた使用して送信します。
