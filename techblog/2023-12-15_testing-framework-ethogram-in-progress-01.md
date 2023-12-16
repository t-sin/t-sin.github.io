:title テストフレームワークをつくる決意をするまで: 前編

:tags>
- プログラミング
- テスト駆動開発
- Lisp
- Common Lisp
- 自作

:description

テストフレームワークをつくっているのでその動機とか試行錯誤とか途中経過とかを書きます。長くなったので前後編に分け、これは前編です。

:content

## アドベントカレンダーの時期ですね

この記事は[Lispアドベントカレンダー2023](https://adventar.org/calendars/9364)の15日目の記事です。遅刻したけど1年くらいぶりの記事だからゆるしてー。

## はじめに

思うところがいくつかあり、[*Ethogram*](https://github.com/t-sin/ethogram)というテストフレームワークをつくっています。この*Ethogram*をつくっていくなかで葛藤とか試行錯誤とかがあったのですが、話の種になりそうで読lみ物として楽しめそうな事柄があったために記事に起こしてみるとおもしろいのではないかなあ、じゃあ書いてみるか、というわけです。

なぜテストフレームワークをつくろうと思ったのか、なにを目指そうとしたのか、それから仕様決めるのに悩み、実装にも試行錯誤し、そんなつくっているテストフレームワークのテスト方法どうするの、そして「テスト駆動開発」の本来意図するところとはなんだったのか、などなど。

ちなみに*Ethogram*自体は実装のとーーーーーーっても初期段階にあり、まだ「テストを書いて走らせる」ということもできない状態です。ただ、この現状に至るまでの試行錯誤 (それはこの記事で述べるものです) によって根幹の設計思想は定まっています。試行錯誤の痕跡を記したこの記事によって「ソフトウェアをテストすること」について考えてみる機会になれたら幸いだなあと思います。

### ちなみにこれは前編です

**この記事は前編**でございます。記事が長くなってきたので分けることにしました。

この前編では、テストフレームワークをつくることになるまでの経緯、直接的なきっかけ、そして既存のものでは何が問題だと感じたのか、までを書きます。

実際につくりはじめるところから現在までは、後編につづく（キートン山田さんの声で）。

## 黎明編 〜 あるいはきっかけ

### 「ぼく、テストを書きたい」

2023年の5月ごろ、とつじょ気づきました。ぼくに不足していたのはテストであったと。

過去につくったプログラムたちに思いを馳せます。[ゲームボーイエミュレータ](https://github.com/t-sin/lambdaboy) ([何年か前の記事](https://github.com/t-sin/shinchoku-advent-calendar-2020/blob/master/articles/2020-12-20.md)) 、[なんか仮想計算機っぽいもの](https://github.com/t-sin/svm) ([記事](https://github.com/t-sin/shinchoku-advent-calendar-2020/blob/master/articles/2020-12-09.md))、[弾幕言語](https://github.com/t-sin/lsd-stg) ([記事](https://github.com/t-sin/shinchoku-advent-calendar-2020/blob/master/articles/2020-12-16.md))、うんぬんかんぬん、有象無象、南無阿弥陀仏。合掌。こやつらについて書いた記事も括弧書きでつけていますが、読むとたいてい「デバッグがつらすぎた」「時間をおくと仕様が忘却され現状のどこが間違っているかわからなかった」とかそういう文字列がちらほらしています。

そして他方、実はテストの重要さについて[kario2さんのc-lesson](https://karino2.github.io/c-lesson/)をやったとき ([c-lesson第一回感想記事](https://t-sin.github.io/techblog/2021-07-21-c-lesson-01.html)) に学んでいたのでした。テストは開発を楽にすすめるために重要なものです。テストフレームワーク自体は使わなかったものの、c-lessonではユニットテストを書く意義「仕様の忘却に備えよ」「壊れた瞬間をすぐ検知せよ」を実感しました。

またそれとは独立して、前職ではGoのBDD (振る舞い駆動開発。後述) スタイルのテストフレームワーク[Ginkgo](https://github.com/onsi/ginkgo)を利用していたり (クリーンアーキテクチャもやってたなあ)、現職ではRubyの[RSpec](https://rspec.info) (こちらもBDDのスタイルです) でテストを書いていました。どちらのフレームワークも*あるていどテストを構造化*して、テストでなにを表現したいのかを明確にしようという思想が根底にあります。

わがだいすきなCommon Lispでの事情はというと、テストフレームワークはかなりの数があります。この記事["Comparison of Common Lisp Testing Frameworks (28 Aug 2023 Edition)"](https://sabracrolleton.github.io/testing-framework)には2023年8月時点のCommon Lispのテストフレームワークが列挙・比較されています。ぼくがつかったことのあるものでも [fiveam](https://github.com/lispci/fiveam)、[Rove](https://github.com/fukamachi/rove)などがありますが、記事に並んだフレームワークは30を越えています。多い。すごい。ただ、この中のほとんどがユニットテストのフレームワークなのです。大抵は式が真になるかテストを定義し、構造化はあまり提供せずユーザにマクロなどを書いてもらって好きに拡張してねという方針のものが多いイメージがあります。あとはテスト結果の整形機能とか、期待値と実際の値をうまく表示したりといったところ。

Common Lispの「最低限の枠組みを用意してユーザに好きにしてもらう」方針と、対するGkingoやRSpecのDSLによる意図を*あるていど構造化して*意図を明確にしようという方針。どちらかを選ぶとすればぼくには後者の方針がよいように感じました。

### ではGinkgoやRSpecたちは最高か？

とはいってもGinkgo (Go) やRSpec (Ruby) にも不満な点はあります。どちらもテストを書くために言語プリミティブを用いたDSLを用います。いまある言語機能でDSLを構成しようとするとまあこうなるのですが、Lispのマクロを知っていると実装に用いている言語プリミティブが表に出てきすぎていると感じます。実装が隠蔽されていないのでたまに奇妙に感じるのです。

また実際にテストを読み書きしていると感じるのですが、GinkgoやRSpecテストの構造化はここまでの文章でわざわざ斜線で強調して「*あるていど構造化*している」と書いているものの、構造化と意味付けが弱いと感じます。複数人で仕事で書いているとグルーピングの単位や`it`の期待値の書き方のスタイルが人によって・時期によって違いすぎると気になります。仕様を正しく把握したいときに読むことだってあるわけです。`it`の中がとってもたくさん確認をしていて意図が不明瞭になりがちだったり。`it`の中でで事前事後の確認をし、しかも複雑な値をスロットごとにしっかり確認をし、といったような。ちなみにここでは、同じ期待値の確認に複数の書き方や語彙があるのは問題にしないものとします。ぼくは気になるけど、本題ではなく枝葉なので。

詳しく述べましょう。

#### 実装が表に出ているDSLは読むうえでノイズになる

これを説明するためにRubyのBDD (振る舞い駆動開発) スタイルのテストフレームワークRSpecのテストコードのサンプルを出してかるく解説をします。

```ruby
# RSpecのドキュメントにあるテストコード例
# from: https://rspec.info/features/3-12/rspec-core/example-groups/shared-examples/

RSpec.describe SomeClass do
  # Reordered code for better understanding of what is happening
  let(:something) { "parameter1" }
  let(:something) { "parameter2" }

  it "uses the given parameter" do
    # This example will fail because last let "wins"
    expect(something).to eq("parameter1")
  end

  it "uses the given parameter" do
    expect(something).to eq("parameter2")
  end
end
```

RSpecの、というかRubyのDSLを構成するのには、メソッドにブロック (`do` ~ `end`あるいは`{` ~ `}`で囲まれた処理。[`Proc`クラスのインスタンス](https://docs.ruby-lang.org/ja/latest/class/Proc.html)。だいだい`lambda式`。[`Method`より使い捨て向きって書いてあった](https://docs.ruby-lang.org/ja/latest/class/Method.html)) を渡すことで中身を遅延評価し、中身の評価時にはDSL専用メソッドを追加した環境で評価するという手が取られます。

上記のコードだと`RSpec.describe`メソッドでテストを記述します。その引数は2つで「説明のオブジェクト (ここでは`SomeClass`というクラスオブジェクト)」と「テスト内容を記述したブロック」が渡っています。`describe`メソッドの引数のブロック内には`let`だとか`it`だとかのメソッド呼び出しがありますが、これらはDSLを構成するメソッドです。

`it`メソッドはテストの本体を記述するメソッドです。`it`に渡されたブロックのなかに`expect`メソッド呼び出しがありますが、ここがテストとして確認したいことを表現しています。`expect`を`it`の外に書くと怒られます (たしか)。`expect`メソッドの返り値によるメソッドチェーンはこれまたDSLになっていて、期待値を確認するためのDSLです ([rspec-expectations](https://rspec.info/documentation/3.12/rspec-expectations/)で定義されています)。

`let`メソッドは`something`という名前に`"parameter1"`という値を束縛した状態をつくることを宣言するメソッドです。値を書くのがブロックの中なのは遅延評価するためで、`let`は各`it`の実行前の初期化のためにあるからです。なんなら`let`で同名の名前を定義すると、評価の1回目は`"paramter1"`、2回目は`"parameter2"`となるようですね。よくできてるゥ。

……と、いうようなのがRSpecのDSLの概要です。

LispおよびCommon Lispだいすき人間にはだいぶ不要な言語要素がぽつぽつあってDSLとして不恰好にみえるわけです。`let`がわざわざブロックで値を引数にとるのは、もし`let`の箇所で`something = "parameter1"`なんてしようものなら、`something`の初期化の後で別の値を代入しようものなら前の値が失われてしまい`it`のタイミングで再初期化ができなくなります。代入はRubyの機構なのでRSpecの制御の下にはないからです。評価を制御するために`let`の名前は変数ではなくシンボルでなければならないし、値は呼ぶと値を返すブロックでなければならないのです。

GoのGinkgoもだいたい似たような感じです。

```go
// Ginkgoのドキュメントより
// from: https://onsi.github.io/ginkgo/

var _ = Describe("Books", func() {
  var foxInSocks, lesMis *books.Book

  BeforeEach(func() {
    lesMis = &books.Book{
      Title:  "Les Miserables",
      Author: "Victor Hugo",
      Pages:  2783,
    }

    foxInSocks = &books.Book{
      Title:  "Fox In Socks",
      Author: "Dr. Seuss",
      Pages:  24,
    }
  })

  Describe("Categorizing books", func() {
    Context("with more than 300 pages", func() {
      It("should be a novel", func() {
        Expect(lesMis.Category()).To(Equal(books.CategoryNovel))
      })
    })

    Context("with fewer than 300 pages", func() {
      It("should be a short story", func() {
        Expect(foxInSocks.Category()).To(Equal(books.CategoryShortStory))
      })
    })
  })
})
```

関数オブジェクトで遅延評価して、RSpecにおける`let`は名前空間をGoでは操作できないので宣言だけしておき`BeforeEach`の引数の関数で初期化をして、うんぬんかんぬん。

Common Lispだったらどうしましょうね。RSpecの`let`は、実装のしかたは`lambda`式にしてもいいでしょうがマクロを書いてそんなものは隠蔽しますよね。適当にいまでっちあげますがRSpecの例に似たテストを定義するDSLを用意するならたとえばぼくなら以下のようにしたいです。

```lisp
(deftest some-class
  :let ((something "parameter1")
        (something "parameter2"))
  :check something :expects "parameter1"
  :check something :expects "parameter2")
```

(`it`の引数文字列は削っちゃいましたが) ブロックとか実装がDSLに表れないので余計な要素がなく、とっても簡潔でステキです。なに？　丸カッコがおおい？　ぼくはLisperなので気になりませんね……。

#### 意味付けや構造化が弱いと読みにくい

GinkgoもRSpecも、`describe`の中に`context` (Ginkgoでは`Context`) をつくって部分をわけることができます。奇数判定をする関数にテストを書くとするとたとえば以下のような構造のテストを書くでしょう:

- `describe "関数isOddのテスト"`
    - `context "引数が偶数"` -> `it "falseを返す"`
    - `context "引数が奇数"` -> `it "trueを返す"`
    - `context "引数が0"` -> `it "falseを返す"`

ただ`context`の分けかたって人によるんです。仕様の観点での場合分けをすることもあれば実装の分岐ベースの場合分けをしたり、同じ引数で読んでても観点ごとにコンテキストを分けることもあれば引数でグルーピングして一気に大量の確認をしていたり、など。あるいはバグを発見したときにバグに対応したコンテキストをつくることもあります。「仕様が記述されている」という期待をもってテストを読むときには不要だが、コードの動作チェックの意味では必要なテストがある、というような悩ましい箇所に遭遇することもよくあります。


この構造化の問題について、明確な答えはまだもっていないものの、なんとか解決できないかしらと日々考えていました。たとえば「context」という語の意味が広すぎるのが問題なのか、もっと明確な意味を持つ語彙でグループをつくることで書く側に構造を意識させるといいのか。でも、冒頭で「同じ期待値の確認に複数の書き方や語彙がある」ことに問題意識を感じてるとぼく自身が書いているぞ。このへんどうするといいのだろう。うんぬん。

あるいは、副作用のテストをするときは事前・事後の確認を重視するし、関数の引数・返り値のペアを単に気にするテストもあるし、そこは書き方が明確に違うべきな気もしなくもない。ただDSLが複雑になると覚えにくさにもなったりはする。むむむ。

## 次回予告

ここまで、モチベーション部分を書き記して前編といたします。

後半では、じゃあこれらの動機からどういうテストフレームワークをつくりはじめたのか、そしてその現在の状況を述べます。

波瀾万丈奇々怪々、奇想天外びっくり仰天。次回もおたのしみに。
