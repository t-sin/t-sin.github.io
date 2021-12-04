:title RustでつくるVST3プラグイン
:tags>
- プログラミング
- デジタル信号処理
- チップチューン
- VST3
- Rust
- アドベントカレンダー

:description

RustでVST3のシンセプラグインを開発できるよ！ という記事です。

:content

この記事は[Rustアドベントカレンダー3](https://qiita.com/advent-calendar/2021/rust)の4日目の記事です。

## はじめに

ぼくはDTM (DeskTop Music) をUbuntu上でやっております。GNU/LinuxでDTMするとなると、Windows/mac向けのシンセサイザープラグインやエフェクトプラグインが (.dllとかなので) 動かない、DAW (Digital Audio Workstation; ざっくり言えば作曲ソフト) の選択肢があまりない、などの制約があり苦労することが多いです。

チップチューン (ファミコンやゲームボーイふうの音楽) が好きなのでたまにつくったりするのですがそのとき、ゲームボーイふうの音が出せるシンセプラグインがGNU/Linux向けのものでは選択肢がほぼなしという状況です。Windowsとかだと[こんなに選択肢ある](https://blog.ajitama-note.com/entry/2021/03/06/215656)のに……どうして……。

DAWにおけるシンセ/エフェクトプラグインの規格として、CubaseというDAWを開発しているドイツのSteinberg社が策定したVST (Virtual Studio Technology) という規格がかなり普及しています。この規格のSDKはC++のインターフェースを持っているのですが、これをRustで呼びだせる[vst3-sys](https://github.com/RustAudio/vst3-sys)というクレートがあることを知ってしまいました。いままでは「C++だから」と敬遠していましたがRustで書けるとなると話は別です。そしてそんなときに、チップチューンシンセがほしいというアイデアもあったため、開発を開始しました。

というわけで、この記事ではRustでゲームボーイ風な音を出すVST3プラグイン[SoyBoy SP](https://github.com/t-sin/soyboy-sp.vst3)を開発している話を書きます。

## VST3とは

まず、VST3について説明しておきましょう。

「はじめに」で述べたとおり、DAWで使えるシンセ・エフェクトのプラグイン規格です。"3"とついていることからわかるように古い規格であるVST2もあります。具体的な違いについてはこちらの["DTMプラグインvst2とvst3の違いについてCPU負荷が軽いのは？ | 96bit-music"](https://96bit-music.com/vst2-vst3/)に詳しいですが、もちろん機能が増えています。たとえば音声信号を64bit浮動小数点で処理できるようになる、など。VST3が開発されたのは2008年だそうですから、2021年においてプラグイン開発をするならVST2を選ぶ理由はあまりなさそうです。

ちなみにVST3についてはこちらの記事["VST3 SDKについて - Qiita"](https://qiita.com/hotwatermorning/items/7f1049a7222aa59a425c)もその現状や問題点がまとまっていて勉強になります。

VST3プラグインを開発するには (通常は) Steinbergの配布するSDKを利用する必要があります。SDKの言語がC++であることが1つの挑戦の障壁になりえますがそれよりも、SDKが必要というのはなんともめんどくさいです。SDKの取得にアカウント登録が必要な気がしていたのですがVST2のころの話であるか、あるいは気のせいでした。アカウント登録は不要です。

### vst3-sys

とはいえSDKを別途ダウンロードして開発するのめんどうだなと思っていたら、RustでVST3プラグインを書けるクレートvst3-sysはSDKレスでプラグインを開発できるというではありませんか。Rustコードを`cargo build`するだけビルドできるということで、楽です。すごくすてきです。これを使うほかないですね。

examplesのコードを実際に手順書どおりにビルドしてみると、たしかにDAWから読み込めるVST3プラグインをつくることができました。SDKレス、ヤバい。万歳。

### VST-MA

しかしSDKレスでプラグインが書ける仕組みはだいぶ謎ですよね。これにはプラグインのアーキテクチャが関わっています。

VST3では[VST-MA (VST Module Archtecture)](https://developer.steinberg.help/display/VST/VST+Module+Architecture) というしくみをプラグインに採用しています。VST-MAはMicrosoftのCOM (Component Object Model) ベースの技術で、COMはバイナリソフトウェアコンポーネントの相互作用をクロスプラットフォームかつ実装言語非依存に実現するしくみのようです。

COMを使うとどうしてクロスプラットフォームになるのかですが、["COM in plain C - CodeProject"](https://www.codeproject.com/Articles/13601/COM-in-plain-C)にあるように、Cレベルのインターフェースが決まっているためそれを守っていれば言語やプラットフォームを問わないやりとりができるという感じらしいです。

vst3-sysクレートも内部に[com-rsクレートのフォーク](https://github.com/RustAudio/vst3-sys/tree/master/com)を内蔵しており、COM越しにやりとりをすることでSDKレスでのプラグイン開発ができるのです。

## `examples/again`を覗いてみる

ではRustでどのようにVST3プラグインを実装するのか、サンプルコードを見てみましょう。

- [vst3-sysのexamples/again (音量調節プラグイン) のソースコード](https://github.com/RustAudio/vst3-sys/blob/425f386d1f012479fe111b17b6203eab55e5e1db/examples/again/src/lib.rs)

なんという物量。そしてなんというunsafeまみれなコードでしょう。COMのやりとりや状態の受け渡しに生ポインタの操作を行うので、VST3のAPIは基本的にunsafeです。このunsafeさと物量に気圧されてはいけません。COMのインターフェースを書くコードは決まりきったことをしているだけなので心を無にして書き写せばなんとかなります。unsafeのほうはというと、たしかにCOM境界部分はunsafeになってしまうのですが、その内側にプラグインの処理本体を書くときはunsafeである必要がないのでunsafeはでてきません。

このサンプルコードでプラグインの本質的なことをやっているのは以下の箇所です:

- [プラグインホスト (DAW) にこのプラグインのI/O情報を教えてている箇所](https://github.com/RustAudio/vst3-sys/blob/425f386d1f012479fe111b17b6203eab55e5e1db/examples/again/src/lib.rs#L182)
- [UIから通達されたパラメータの変更を取り出している箇所](https://github.com/RustAudio/vst3-sys/blob/425f386d1f012479fe111b17b6203eab55e5e1db/examples/again/src/lib.rs#L416)
- [毎サンプルごとの信号の計算をやってる箇所](https://github.com/RustAudio/vst3-sys/blob/425f386d1f012479fe111b17b6203eab55e5e1db/examples/again/src/lib.rs#L181)

VST3では (VST2もそうだったみたいですが) 信号処理部とパラメータ操作部が別スレッドで走ります。そのため信号処理部だけを実装したサンプル[passthru.rs](https://github.com/RustAudio/vst3-sys/blob/425f386d1f012479fe111b17b6203eab55e5e1db/examples/passthru.rs)では、DAWに読みこんでもパラメータなしのプラグインと認識されます。

VST3プラグインのつくりかたについて、["VST3プラグインの作り方 | C++でVST作り"](https://www.utsbox.com/?page_id=1316)がとても詳しいので紹介しておきます。

## 正弦波を鳴らしたい

上の例は単純なエフェクトプラグインでした。でもせっかくVST3プラグインが書けるのですし自分で音を生成して鳴らしたいですよね。DAWから送られてくる音符のオン・オフ情報に反応してサイン波の音を鳴らすシンセサンプルが、あればいいのに。なぜないのか。こんなのおかしいよ。むむむ。だれか…。生えろ…！ 生えてきてくれ…！！ 

生えました🥳: <https://github.com/t-sin/rust-vst3-example>

こんなふうに使えます。

<iframe width="560" height="315" src="https://www.youtube.com/embed/0sohZOrF6R4" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

### アーキテクチャ

Piというシンセを用意してみました。正弦波の音が鳴るだけですが、unsafeなVST3との境界世界とプラグインでやりたいことを実現する部分をモジュール毎わけています。図にするとこんな感じです。

```
+-----------------+
| DAW (VSTホスト) |
+-----------------+
       ｜
       ｜初期化してイベントとか通達
       ｜
       ↓
+----------------+  信号くれー         +--------------+
| plugin.rs      |  イベントきたよー   | piモジュール |
| (unsefeな世界) |  ---------------->  | (safeな世界) |
+----------------+                     +--------------+
       ↑
       ｜ (VSTホストを介して)パラメータとか通信
       ↓
+----------------+
| controller.rs  |
| (unsefeな世界) |
+----------------+
```

vst3-sysを介して外界とやりとりのを担当するコードが`src/vst3`ディレクトリにあり、`plugin.rs`が音声処理部のコードで`controller.rs`がパラメータのGUIからの操作を受けるコードです。

`src/pi`ディレクトリに入っているのが実際にサイン波信号を計算し、イベントがきたら音の生成パラメータを変更するなどの「やりたいこと」をやっているコードです。

### VST3の信号処理部でやること

VST3の信号処理部のメイン処理は`IAudioProcessor`トレイトの`process`関数です。ここで

1. 操作されたパラメータの処理
2. 外部から入力されたイベント (音鳴らせ！など) の処理
3. 信号の計算

をやります。

そのうち信号の計算は、信号をまとめて計算し関数引数で渡されたバッファ (生ポインタ) に格納します。バッファを用いるのは (音系プログラムではよくあるのですが) サンプリング周期ごとに信号を計算していたら処理のオーバーヘッドが大きいからです。サンプリング周期、一般的には44.1kHzとかですからね。たいへんです。

ともあれ、ここでは単にバッファのサイズ分だけ`PiSynth`構造体のprocessメソッドを呼んで終わりです。音のオンオフ等の処理は`process`メソッドの中でやっています。

```rust
// https://github.com/t-sin/rust-vst3-example/blob/293f09118721fb425a6f1208be1686947b6ec1e3/src/vst3/plugin.rs#L365

        match data.symbolic_sample_size {
            K_SAMPLE32 => {
                for n in 0..num_samples as isize {
                    let s = self.pi.borrow_mut().process(sample_rate);

                    for i in 0..num_output_channels as isize {
                        let ch_out = *out.offset(i) as *mut f32;
                        *ch_out.offset(n) = s.0 as f32;
                    }
                }

                kResultOk
            }
        ...
```

### Piの信号処理

Piのprocessメソッドは、自前の`AudioProcessor`トレイトのメソッドでした。ノートオン (音を鳴らす) 状態のときには計算した信号を返し、そうでないときは無音としています。

```rust
// https://github.com/t-sin/rust-vst3-example/blob/293f09118721fb425a6f1208be1686947b6ec1e3/src/pi/mod.rs#L75
impl AudioProcessor<Signal> for PiSynth {
    fn process(&mut self, sample_rate: f64) -> Signal {
        let osc = self.osc.process(sample_rate);
        let v = if self.note_on { 0.3 * osc } else { 0.0 };

        (v, v)
    }
}
```

`self.note_on`はVST3側のイベントの処理で`Triggered`トレイトを通じて変更しています。興味がありましたら見てみてください。

### 正弦波の計算

正弦波の計算をするオシレータの処理はこのようになっています。

```rust
// https://github.com/t-sin/rust-vst3-example/blob/293f09118721fb425a6f1208be1686947b6ec1e3/src/pi/sine.rs#L37
impl AudioProcessor<f64> for SineOscillator {
    fn process(&mut self, sample_rate: f64) -> f64 {
        let phase_diff = (self.freq * self.pitch) * 2.0 * std::f64::consts::PI / sample_rate;
        self.phase += phase_diff;

        self.phase.sin()
    }
}
```

`self.phase`は`sin(x)`の`x`の部分です。こいつを所望の音の高さ (周波数) になるように動かしていくと、音階がだせます。`self.freq`が現在鳴らしている音の周波数で、`self.pitch`は「パラメータで鳴ってる音の高さちょっと変えたいな」というとき用のモディファイアです。デジタル信号において、ある周波数の信号がほしいとき`x`の値の増分は`f * 2 * PI / sample_rate`なので、fの部分に`self.pitch` (比) と`self.freq` (Hz) を掛けたものを代入したのが`phase_diff`の右辺です。

このあたりの計算は慣れればなんとなく書けるようになります。ご安心ください。

## 自作チップチューンシンセSoyBoy SP

これらのことを踏まえてもりもりと実装していっているのが、[SoyBoy SP](https://github.com/t-sin/soyboy-sp.vst3)というVST3シンセです。GNU/Linuxでもチップチューンするんだもんという強い意思の顕れです。このシンセはゲームボーイふうの音をつくることができ、以下のような機能があります。

- 3つのオシレータ
    - 矩形波 (duty比選択可)
    - ノイズ (ノイズ周期選択可)
    - 波形テーブル (テーブル編集可)
- なんちゃってDAC機能 (ローパスフィルタ)
- MIDIのピッチベンドに対応
- 矩形波オシレータには周波数モディファイア搭載
- ノートディレイ搭載

現状、実装しようと思っていた機能は全て実装が完了しており、専用のGUIを用意する準備中という段階です。GUIのデザインはだいたい確定していて ([モックがこれ](https://github.com/t-sin/soyboy-sp.vst3/blob/e5811f7f782ade8fff8b994df72b9fa85c1cc1ce/doc/soyboy-ui-mock.png)) 、あとは実装するのに[OrbTk](https://github.com/redox-os/orbtk)を用いるか[egui](https://github.com/emilk/egui)を用いるか、どちらにしようかなあと悩んでいます。

## まとめ

本記事では

1. VST3プラグインをつくりたい背景を述べ、
2. VST3プラグインとは何かを説明し、
3. VST3プラグインの実装方式を簡単に説明し、
4. つくっているVST3プラグインの紹介をしました。

音系のアイデアをソフトウェアとして試作するときVST3プラグインとして使えるように実装しておくと、DAWの機能 (譜面の再生、他のエフェクトとの協調、GUI) を使ってデバッグや試験ができるので便利だと思います。一度なにかを実装して覚えておきそれをテンプレートとして使い回せるようにしておくと、以降の試作が簡単になりそうだなあと感じました。

みなさんも気軽にシンセやエフェクトをつくってみてください。では、Happy Hacking！

## おまけ

むかしに「ファイルシステムを操作すると音がでる」というプログラムをRustで書きました。[Koto](https://github.com/t-sin/koto)といいます。使いやすいとは言えないですが、初Rustプロジェクトで思い入れが深いので宣伝でした。
