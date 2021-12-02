:title 自作言語tanaka-lispの進捗報告
:tags>
- プログラミング
- 言語処理系
- 言語実装
- Lisp
- C言語
- Lispアドベントカレンダー

:description

絶賛開発中の自作言語tanaka-lispの進捗報告をします。

:content

この記事は[Lispアドベントカレンダー2021](https://qiita.com/advent-calendar/2021/lisp)の2日目の記事です。

## TL; DR

自作Lispはじめました。

## はじめに

自作言語をするとき言語をどう設計したらいいかわからないとつぶやいたら、Matzさんの[『まつもとゆきひろ 言語のしくみ』](https://www.nikkeibp.co.jp/atclpubmkt/book/16/258860/)がよいと教えてもらいました。読んでみると、言語をつくろうとするときの思考過程が述べられております。設計の過程で他の言語のことを意識しつつさまざまな決定がなされていき、なんだかぼくも言語を設計してみたくなってしまいました。

そこでつくりはじめたのが[tanaka-lisp](https://github.com/t-sin/tanaka-lisp)です。Lisperであるのでつくる言語はLispがよく、でもどんな機能を乗っけるかはまだまだ妄想が必要で、ああもういったいどうなっちゃうの。この記事ではそんなtanaka-lisp実装の2021-12-02時点での進捗を記します。

## tanaka-lispとは

まずは自作言語tanaka-lispの機能や目標を述べます。紆余曲折があったもののこの言語で何をするのかは[11月5日に完全に確定](https://github.com/t-sin/tanaka-lisp/commit/a7a612374ea4cea6ade2d9516a78df6d8d30eb25)しました。ここでは完成したらどんな言語であるかを書きます。

tanaka-lispはオブジェクト指向Lispです。Lispというと[SICPの表紙](https://mitpress.mit.edu/sites/default/files/sicp/index.html)からイメージされるように`eval`と`apply`を基礎としてつくるイメージがあると思いますが、tanaka-lispはオブジェクト指向なので、メッセージの送信を基礎におきます。tanaka-lispでは以下のようなコードを実行できます。

```lisp
;; https://github.com/t-sin/tanaka-lisp/blob/46a5346b51321ef4dfe8a9616e7cd665cebd5c60/examples/layer2/02-define-message.lisp
;; message definition example

(defmsg pulse (type float)
    (duty)
  (if (> self duty)
      1.0
      0.0))

(pulse 0.0 0.5)
; => 0.0

(pulse 0.8 0.5)
; => 1.0

(pulse 1 1)
; -> unknown message (because `1` is integer)
```

やっているのは0.0 ~ 1.0の定義域で矩形波の値を返す関数の定義と、その利用です。見た目はただのS式のコードなのですが、一見してLispっぽくないといころは`defmsg`でしょうか。これは`defun`や`defn`に相当する、メッセージ定義のためのメッセージ送信式です。`pulse`というシンボルオブジェクトは`defmsg`を受け取ると、引数や本体部分をグローバルな辞書に登録します。「引数」や「本体」はリストオブジェクトをそのまま渡します。呼び出してるところでは、パース結果である`(pulse 0.8 0.5)`というリストオブジェクトに`eval`メッセージを送ると、先頭がシンボルオブジェクトならメッセージ辞書の対応する処理を呼ぶ感じです。

ちなみにメッセージを受けるとき引数は評価されずにパース時のオブジェクトがそのまま渡ってくるので、評価するしないはメッセージのレシーバが決めます (つまり評価が本体評価時に遅延される)。すると、いわゆるLispの伝統的マクロのようなものも実現できます (そういえば上の例、引数評価してないな…)。なので上の例の`if`もメッセージ送信です。

というように、tanaka-lispはオブジェクト指向を根っこに据えたつくりになる予定です。このアイデアはぼくのオリジナルではまったくなく、g000001さんの記事[「#:g1: Metaobject Protocol及び関連技術についての個人的まとめ」](https://g000001.cddddr.org/3839726255)に書かれているMOPが目指したもの、およびOpen Implementationという概念にとてもインスパイアされています。

## 目標

言語をつくったらそれで何かしてみたいですよね。tanaka-lispではオブジェクト指向な言語を実現したあと実用として何をするのかというと、いわゆる[タートルグラフィックス](https://ja.wikipedia.org/wiki/LOGO#%E3%82%BF%E3%83%BC%E3%83%88%E3%83%AB%E3%82%B0%E3%83%A9%E3%83%95%E3%82%A3%E3%83%83%E3%82%AF%E3%82%B9)をやります。LOGOのあれです。tanaka-lispでは[アニメ『オッドタクシー』](https://oddtaxi.jp)の[田中](https://oddtaxi.fandom.com/wiki/Hajime_Tanaka)にインスパイアされて「ドードーグラフィックス」と呼ぶことにしましたが、亀です。

tanaka-lispではドードーオブジェクトにメッセージを送って、その結果をPGM画像として出力する機能を実装し終えた時点で完成とすることにしました。言語のひと通りの機能を試した上でメディア処理っぽいことができるし、[ブレゼンハムのアルゴリズム](https://ja.wikipedia.org/wiki/%E3%83%96%E3%83%AC%E3%82%BC%E3%83%B3%E3%83%8F%E3%83%A0%E3%81%AE%E3%82%A2%E3%83%AB%E3%82%B4%E3%83%AA%E3%82%BA%E3%83%A0)くらいの複雑さの計算ができることも示せます。達成できたらステキですね。

## 紆余曲折の仕様策定

さて、この仕様と目標が定まるまでは紆余曲折がありました。設計のはじめからドードーグラフィックスをしたかったわけではないですし、オブジェクト指向っぽさも言語の機能をどうするか模索していたときに思い付いたものです。ここではどうやってオブジェクト指向に辿りついたのかを述べることで、言語設計の過程を晒しておきます。

tanaka-lispの言語設計で最初にやったのは、機能やコンセプトはともあれコードがどういう見た目をしているかを考えることでした。[Hello world](https://github.com/t-sin/tanaka-lisp/blob/bb8b14d20c5e89ff8ad25156c8cf546f912e68ea/examples/layer1/01-hello-world.lisp)はどう書くのか、[制御構文](https://github.com/t-sin/tanaka-lisp/blob/bb8b14d20c5e89ff8ad25156c8cf546f912e68ea/examples/layer1/03-control-flow.lisp)は、というようなかんじで。Common Lispが好きなので意識をしつつ、「ぼくならこうあってほしいな」という好みを探りつつ書いていきました。

ところでtanaka-lispは最初、共有ライブラリとして組み込み可能なLuaっぽいLisp言語で弾幕を記述することを目標にしていました。参考元であるLuaではハッシュテーブルに特殊なスロットがあるとオブジェクトになるのですが、それを真似してオブジェクト指向できると楽しいのではーとおもってモックをつくりながら (モックについては後述) 以下のような例をつくりました。

```lisp
;; https://github.com/t-sin/tanaka-lisp/blob/bb8b14d20c5e89ff8ad25156c8cf546f912e68ea/examples/layer1/06-oop.lisp
;; object oriented programming example

;; creating classes
;; `#{}` is a hash table literal
;; class is a hash table that has a hash table named as `*meta*`
(setq *animal*
  #{:*meta* #{:name :animal :parent nil}
    :say (lambda (self) (format t "Animal!\n"))})
; => #{...}

(setq *dodo*
  #{:*meta* #{:name :dodo :parent *animal*}
    :say (lambda (self)
              (send :say (get (get self :*meta*) :parent))
              (format t "Dodo!!\n"))})
; => #{...}

(send :say *animal*)
; => Animal!

(send :say *dodo*)
; => Animal!
;    Dodo!!
```

このとき、そういえばRubyに`method_missing` (Smalltalkの`doesNotUnderstand`) なる機能があったなと思いだしたのでモックに実装してみたのです。

```lisp
;; https://github.com/t-sin/tanaka-lisp/blob/bb8b14d20c5e89ff8ad25156c8cf546f912e68ea/examples/layer1/06-oop.lisp のつづき
;; Smalltalk's `doesNotUnderstand`
;; or Ruby's `method_missing`
(setq obj #{:*meta* #{:parent nil}
            :unknown-message (lambda (self msg &rest args)
                               (cl:format t "unknown message ~s with args: ~s" msg args))})

(send :hoge obj 1 2)
; => unknown message :hoge with args (1 2)

;; utilities
(make-object :dodo *parent-object*)
; => #{:*meta* #{:name :dodo :parent *parent-object*}}

(define-message say dodo ()
  (format t "say dodo!\n"))

(send :say dodo)
; => say dodo!
```

これがまた動くんですよ。動いたのです。そして`はじめに`でも挙げたg000001さんの記事の影響もあって、組み込み言語という目標を捨てオブジェクト指向言語への道を進むことにしたのでした。

オブジェクト指向について試行錯誤していると`(send :say dodo)`は単に`(say dodo)`でいいような気持ちがしてきます。オブジェクト指向できるだけの力を得たら`apply`による計算の世界から、メッセージ送信`send`による計算の世界へ移行できると思いました。またSmalltalk-72ではメッセージ送信時に評価がされないということを知ったり、MOPの記事でも触れられていた「メッセージをオブジェクト自身が評価する」からのインスパイアもあって、Lispの世界の上にリーダも評価プロセスもぜんぶオブジェクトとメッセージにした、オブジェクトの世界を構築するという目標が生まれました。

## モックの作成

言語設計を試行錯誤するときに、その対象言語が不完全ながらも存在していると使ってみないとわからないような使いにくさを洗い出す助けになります。[cxxxrさん](https://github.com/cxxxr)から「Common Lispでモックしてみては？」と言われてやってみたのが[prototypeディレクトリ](https://github.com/t-sin/tanaka-lisp/tree/master/prototype)です。

tanaka-lispはわりとオーソドックスな見た目のLispなのでCommon Lispの処理系の一部を使い回せそうです。リーダは使い回せますし、評価システムもそうです。なので`tanaka-lisp`パッケージをつくって`defpackage`の`:use`を`nil`にして空パッケージを作成し、そこにtanaka-lispのオペレータを実装していくことで、SLIMEでtanaka-lispを体感しながら言語仕様を決めていくことができました。

たとえば、繰り返しのためのLispレイヤーの特殊形式`loop`はモックでは以下のように定義されています。

```lisp
;; https://github.com/t-sin/tanaka-lisp/blob/bb8b14d20c5e89ff8ad25156c8cf546f912e68ea/prototype/layer1.lisp#L60
(cl:defmacro loop (&rest args)
  `(cl:loop
     :while ,(let ((while-clause (cl:getf args :while)))
               (if while-clause
                   while-clause
                   t))
     :do ,(cl:getf args :do)))
```

`loop`特殊形式は以下のように

```lisp
;; https://github.com/t-sin/tanaka-lisp/blob/bb8b14d20c5e89ff8ad25156c8cf546f912e68ea/examples/layer1/03-control-flow.lisp#L9
;; loop
(let ((n 0))
  (loop
    :while (< n 3)  ; conditional form (optional)
    :do (do         ; body
          (format t "n = {}\n" n)
          (set n (1+ n)))))
```

利用するものですがこれをまさにCommon LispのREPLで試せるので使いにくさを即検知できます。

難点があるとすれば、それはモックをつくりこみすぎると充足が訪れるので言語を実装した感が得られてしまって、その先の本実装に到達できない可能性があることです。それがゴールド・E・レクイエム。

## C言語による実装

モックでの試行錯誤が終わったので11月の頭からC言語による実装をスタートしました。今回はインクリメンタルに開発していくことを念頭に置いて[ロードマップを先に作っておきました](https://github.com/t-sin/tanaka-lisp/blob/bb8b14d20c5e89ff8ad25156c8cf546f912e68ea/TODO.md)。入力をエコーするだけのREPLから出発して、真理値`#f`/`#t`だけを処理するREPL、整数、ドット対……と徐々に機能を付け足していくつもりです。

## 現在の状態

本記事を書いている時点での[最新コミットはこちら](https://github.com/t-sin/tanaka-lisp/commit/bb8b14d20c5e89ff8ad25156c8cf546f912e68ea)です。ドット対の実装ではたくさんmallocしそうなので、このタイミングでGCを実装するために試行錯誤しているところです。ぼくはGC実装が今回人生初なのでものすごく手探りでいろいろ決めていっていますが、tanaka-lispのGCは以下のようにしようと思っています:

- preciseなGC
    - 必要なデータは言語がすべて知っているため
    - false pointersに悩まされるとつらそうなので
- copying GC
    - フラグメンテーションを考えなくてよい
    - マーク＆スイープ方式だとコンパクションがぜったい要るよね？ 要るよね？？

骨があって楽しめそうですね。

## 今後のこと

あとはひたすら実装していくだけなのですが、継続の実現だったり、途中で止められるパーサだったり、大きなものもつくらねばならないのでじっくり楽しめそうです。GCもありますしね。

とりあえずここ数日、退職＆入社によってGC進捗まったく皆無だったのをなんとかせねばあるまい……。
