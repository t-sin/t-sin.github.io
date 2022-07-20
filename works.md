:title Works
:description つくったものなどの紹介ページ

:content

# Works

## publications

- [『3つのLisp 3つの世界 (Three Lisp in Three Weeks)』](https://paren-holic.booth.pm/items/1317263), 共著, 技術書典6
- [『Lispとコンピュータ音楽 Vol.1 (Lisp and Computer Music)』](https://paren-holic.booth.pm/items/1575612), 単著, 技術書典7

## music

### discography

- [First Commit](https://sushihamburg.bandcamp.com/album/first-commit) (「ハンバーグめっちゃ旨え」名義)
    - [@carrotflakes](https://github.com/carrotflakes)さんとのユニットの初アルバム。エレクトロニカ。
- [Roudou](https://sushihamburg.bandcamp.com/album/roudou)  (「ハンバーグめっちゃ旨え」名義)
    - [@carrotflakes](https://github.com/carrotflakes)さんとのユニットの2つめのアルバム。「労働」がテーマ。

## events

- [進捗アドベントカレンダー2020](https://github.com/t-sin/shinchoku-advent-calendar-2020)
    - ちゃんと外部に話していないことを書いてみるアドベントカレンダー。

## software projects

### Lisp系

- [Inquisitor](https://github.com/t-sin/inquisitor) (Common Lisp)
    - 文字コード・改行コードの判定と、Common Lispのextrenal-formatの処理系依存な抽象化を行うライブラリ。
- [ros-tap](https://github.com/t-sin/ros-tap) (Common Lisp)
    - [Roswell](https://github.com/roswell/roswell)の起動時にロードされるプロジェクトを登録・削除できるようにするサブコマンド。
- [LLGLL.ja](https://github.com/t-sin/LLGPL.ja) (Markdown)
    - Lisp GNU General Public License (LLGPL) の条文の日本語訳。原文は[Franz Inc.によって作成](http://opensource.franz.com)されました。

### 実用できる系

- [Soyboy SP](https://github.com/t-sin/soyboy-sp.vst3) (Rust)
    - チップチューン向けVST3プラグイン。
    - [公式サイト](https://t-sin.github.io/soyboy-sp.vst3/)もあります。
    - ビルド済みバイナリはBOOTHにて頒布中: [無料版](https://bak-shaver.booth.pm/items/3914414)、[お布施版](https://bak-shaver.booth.pm/items/3871410)
- [Asha](https://github.com/t-sin/asha) (Common Lisp)
    - 静的サイトジェネレータ。
    - もともとは『3つのLisp 3つの世界』のためのコードサンプルだったが、ブログ移行のため本格改造中。
- [Rosa](https://github.com/t-sin/rosa) (Common Lisp)
    - テキストデータにメタデータを付与する構文を与える言語。
    - パーサがついている。
- [Niko](https://github.com/t-sin/niko) (Common Lisp)
    - GitHubのissueやPR上でメンションをもらったときにSlackで通知してくれるSlack bot。

### メディア・インタラクティブ系

- [Koto](https://github.com/t-sin/koto) (Rust)
    - ファイルシステムで音を奏でるソフトウェア。FUSE越しにシンセサイザーの内部状態を操作するもの。
    - 内部ではTapirusを利用している。
    - [特設ウェブサイト](https://t-sin.github.io/koto/)つき。
- [Tapirus](https://github.com/t-sin/tapirus) (Rust)
    - Kotoの内部で用いているシンセサイザーエンジン。
    - 信号処理ユニットを接続することで音づくりできる。
    - [ここにrationaleを書きました](https://github.com/t-sin/shinchoku-advent-calendar-2020/blob/master/articles/2020-12-01.md)。
- [Alrair](https://github.com/t-sin/altair) (Nim)
    - プログラム可能なシンセサイザー。Nimのv1.0.0がでたのでつくってみた。
    - こちらに[製作過程的なもの](http://octahedron.hatenablog.jp/entry/2020/03/06/085854)を記しています。

### ゲーム系

- [天書](https://github.com/t-sin/tensho) (JavaScript)
    - 円城塔『文字渦』のパロディ。
- [LambdaBoy](https://github.com/t-sin/lambdaboy) (Common Lisp)
    - 実装中のゲームボーイエミュレータ。

### 実験系

- [LISC](https://github.com/t-sin/lisc) (Python)
    - Pythonのリスト内包表記によるワンライナーで書かれたLisp処理系。
- [One](https://github.com/t-sin/one) (Common Lisp)
    - Common Lispでワンライナーをしたかった、というライブラリ。

### 試作系

- [Pukunui](https://github.com/t-sin/pukunui) (Common Lisp)
    - サウンドプログラミング実験。ユニットジェネレータ方式で信号処理ができる。
    - 将来的には自分用サウンドライブラリになる予定。
- [Nuts Lisp](https://github.com/t-sin/nutslisp) (Nim)
    - 初めてつくったLisp処理系。頓挫とかした。
- [Mark](https://github.com/t-sin/mark) (C)
    - Lispでリスを実装するプロジェクト。
- [tanaka-lisp](https://github.com/t-sin/tanaka-lisp) (C)
    - あるていど本格的なLisp処理系を作ってみるプロジェクト。
    - Smalltalk-72方式オブジェクト指向を目指してる。
