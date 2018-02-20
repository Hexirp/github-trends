# github-trends

[![Build Status](https://travis-ci.org/Hexirp/github-trends.svg?branch=master)](https://travis-ci.org/Hexirp/github-trends)

GitHubが提供しているHaskellリポジトリの[トレンド](https://github.com/trending/haskell)をスクレイピングしてslackに投稿するプログラムです。[日本Haskellユーザーグループ](https://haskell.jp)の[公式Slack](https://haskell-jp.slack.com/)でトレンドを見たくて作りました。もちろん、Haskell製です！

## 仕組み

トレンドのスクレイピング及び整形を行った後、引数に渡された[古いタイプのSlackトークン](https://api.slack.com/custom-integrations/legacy-tokens)を使って投稿します。見ての通り非推奨なのですが、新しいタイプのトークンはapp数を消費してしまうみたいなのでこの方法をあえて選択しています。

デプロイはTravis CIで行っています。デプロイの時にプログラムを実行するようにして、Cron機能を使って毎日ジョブを実行させています。古いSlackトークンはパスワードと同等に扱わなければならない代物なのでEncrypt機能を使って隠しています。

### 形式

```
(新しいトレンドの番号付きリスト)

(全てのトレンドの番号付きリスト)
```

### 内部

[http-conduit](https://hackage.haskell.org/package/http-conduit)ライブラリを使用して[日刊トレンドのページ](https://github.com/trending/haskell?since=daily)と[週刊トレンドのページ](https://github.com/trending/haskell?since=weekly)を取得します。その後、[html-conduit](https://hackage.haskell.org/package/html-conduit)ライブラリを使用してXMLデータとして読み込み、[xml-conduit](https://hackage.haskell.org/package/xml-conduit)ライブラリを使用してリポジトリ名をリストの形で取り出します。ここで、日刊トレンドのリストを`daily`、週刊トレンドのリストを`weekly`とします。

「新しいトレンド」は`daily`から`weekly`に含まれるものを間引いたもので、「全てのトレンド」は`daily`です。新しいトレンドがこのように定義されている理由は、「ずっと日刊トレンドに入り続ける古いトレンドであるリポジトリなら、週刊トレンドにも入っているだろう。よって、週刊トレンドに入っていないリポジトリは新しいトレンドであろう」という予測によります。
