:title われわれが必要なすべてはLOVE
:tags>
- プログラミング
- Lua
- ゲーム
- ゲームエンジン
- 自作

:description

LOVEというLuaで書けるゲームエンジンの紹介です。

:content

## 愛をみつけてしまった

近ごろ、かわいいゲームエンジンを見つけてしまってLuaにハマっています。そのゲームエンジンはLÖVEという名前のエンジンで、なぜかわいいのかは公式ウェブサイトを見るとわかります。

[LÖVE - Free 2D Game Engine](https://love2d.org)

ポップでかわいらしいデザインのウェブサイトで、その見た目にノックアウトされて触ってみるとかなり高速でいい感じです。特徴を上げておくと

- 2Dゲーム用のエンジン
- クロスプラットフォーム
    - iOSやAndriodアプリも出力できるようです
- ゲームの記述言語はLua (with [LuaJIT](https://luajit.org))
    - エンジン自体はほぼすべてC++で書かれている
- グラフィックやIO、サウンドまわりの抽象化
    - 剛体力学シミュレーション込み
- ゲームのメカニズム (状態遷移とか) は入ってない

という感じです。SDLの上につくられており、薄いゲームエンジンといった風情のようです。

## コードはどんな感じ？

[こんな感じのパーリンノイズ可視化](https://github.com/t-sin/love-sketches/blob/master/2021-05-25-noise-circles/noise-circles.png)が以下のように書けます。

```lua
function love.load()
    z = 0
end

function love.update()
    z = z + 0.01
end

function love.draw()
    love.graphics.clear(0.08, 0.03, 0.084)
    love.graphics.setBlendMode("add")
    love.graphics.setColor(0.4, 0.5, 0.8, 1)
    for y = 0, love.graphics.getPixelHeight(), 30 do
        for x = 0, love.graphics.getPixelWidth(), 30 do
            n = love.math.noise(x / 100 , y / 100, z)
            r = n * n * 30 + 1
            love.graphics.circle("line", x, y, r)
        end
    end
end
```

ここでは`love`モジュールが提供するコールバック関数を3つオーバーライドしています。なんとなく想像がつくと思いますが、`love.load()`は起動したとき1回だけ実行され主に状態初期化やリソース読み込みなどに理想します。`love.update()`は状態の更新を行うためのものです。`love.draw()`は状態を利用して画面に描画するためのコールバック関数です。

ところでこの可視化のプログラム、以前[ジェネラティブアートとして書いたもの](https://github.com/t-sin/my-generative-art-sketches/blob/master/perlin-circles.lisp)の焼き直しなのです。

そう、そうなんです。

ゲームエンジンってジェネラティブアートにも向いてるんですね（学び）。

ちなみに同じことを[Quil](http://quil.info) (ProcessingのClojureラッパーライブラリ) でやるとけっこうもたつくのですが、LOVEなら60fpsでぬるぬる動きます。ProcessingやQuilではアニメーション関連はオブジェクト数が多くなると重くなってくるのであまり気軽には試せなかったんですが、これならほんとうに気軽にアニメーションできてよいです。好き。Common Lispにこのレベルのライブラリがほしくなってしまいます。

## lua-modeがほしい…

ちなみにふだん使いのテキストエディタは[Common Lisp製のLem](https://github.com/lem-project/lem)なのですが、これにはまだlua-modeが存在しないので、fundamental-modeでコードを書いています。つらい。せめてシンタックスハイライトとオートインデントがほしい。

なので、どこかでlua-modeを書いてpull requestをださねばならない。

## 今後どうするの？

これだけ気軽にできるなら、ということでスケッチを溜めていくためのリポジトリをつくりました。

[t-sin/love-sketches](https://github.com/t-sin/love-sketches)

いまは簡易クリックゲーム的なものをつくろうとして四苦八苦しています。これ以降も、ジェネラティブアートっぽいことや、ゲーーム的なものなどをスケッチしていろいろ試してみようと思います。
