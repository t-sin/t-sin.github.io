:title ちいさくて音と映像が同期するかっこいいやつ
:tags>
- プログラミング
- 音楽
- ジェネラティブアート
- ゲームエンジン
- Lua

:description

LuaのゲームエンジンLoveをつかって、音とグラフィックのコラボレーション実験をしてみました。

:content

## モチベーション

音と映像が絡みあうような作品・体験がすきです。

そういう作品があると知ったのは、PlayStation 2の『Rez』とPlayStationの『DEPTH』に触れたときでした。以降、『Rez』を製作した水口さんの作品を追いかけて、『Child of Eden』 (MatrixやPassionがアツいですが極めつけはHopeです)、『Rez Infinite』 (Area Xは衝撃ですね。ところどころChild of Edenのアイデアが息づいているのも胸アツです)、そして『Tetris Effect』 (The DeepとDolphin Surfがすっっっごくすきです。そういえば[ファンアート描いてました](https://twitter.com/sin_clav/status/1267466216106426372))と、どれも最高ですね。『Tetris Effect』と『DEPTH』ではイルカ要素も共通していたりして、すき・オブ・すきです。

自分でもこういうものをつくってみたいと思いつづけ、サウンドづくりやら、サウンドのプログラミングやら、グラフィックのプログラミングやらに挑戦しつづけて (は挫折して) きました。

そろそろなんかできないでしょうか。音とアート映像を融合させたくないのはなぜでしょうか。

答えは挑戦してないからです。

なんとなく原理的にどうやればいいかはわかっているのにやらないのは、正確にはCommon Lispでいい感じの環境がまだないことも関係してはいるものの、そろそろ挑戦したくなってきました。そういえば[Luaの2Dゲームエンジンでいいのをみつけたという記事](2021-05-28-game-engine-love.md)を書いてもいましたしね。

そろそろ手をつけてみるかー。と、そういう感じで挑戦してみました。

## つくるものの方針

ちなみに表題のものをつくる3日くらい前に同じように「そろそろ手をつけるかー」ということで、[プログラム生成アート映像もどき](https://www.youtube.com/watch?v=qeGCEZAqV_c)をつくっていました。なのでこの路線でいきます。この動画では[Love](https://love2d.org)で生成しているそれっぽい映像に[それっぽい自作の音楽](https://soundcloud.com/sin_clav/hi-1)を流しているだけですが、こんどは自作の曲とプログラムで生成する映像を同期させます。

音楽のほうは、くっきりカッコいい感じの曲だと (そんな曲つくれたことないですが) タイトにタイミングを合わせないといけなさそうなので、なんかゆるくてふわっとしたやつがいいです。過去の自作曲を漁ればなんかでてくるでしょう。

映像部分は、ほんとうは『Rez Infinite』のArea Xとか『Tetris Effect』のThe Deepばりの激エモブチ上げシェーダ盛り盛りのキラッキラしたグラフィックを用意したいところですがいまはまだ無理なので、あと複雑なことを考えるとモノができあがらないので、シンプルにいきます。なんか丸が音に合わせて出てればええんちゃう？ しらんけど。

そういえばLoveに挑戦しはじめたころ、ゲームつくろうとしてたなあ。こんなやつを。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">自作の音楽をつけた。いっそこれで完成に…？ <a href="https://t.co/EZa5UDmTMZ">pic.twitter.com/EZa5UDmTMZ</a></p>&mdash; t-sin🥳 (@sin_clav) <a href="https://twitter.com/sin_clav/status/1397523682424090630?ref_src=twsrc%5Etfw">May 26, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

曲もこのやつで、なんかこんな雨っぽい感じで、できないですかねえ。

ここでは以下のような方針で攻めました

- Luaの2Dゲームエンジン[Love](https://love2d.org)を用いる
- 曲はこれ <https://soundcloud.com/sin_clav/drop> をつかう
    - 自作なので権利関係オールクリアなので
    - 作曲ソフトの譜面データがあるのでなんかできるっしょ
- なんか音の鳴りはじめに合わせて波紋がでる (ﾊﾟﾊﾟｳﾊﾟｳﾊﾟｳ)

## 音楽に合わせたイベントを発生させるには

さて、この曲のマスタリングされたデータが`drop.mp3`です。これに合ったかたちでゲームループ内でイベント「波紋が発生」を起こさなければなりません。ただもちろん`drop.mp3`はPCMデータ、波形データなので各音が鳴るタイミングなんて入っていません。

でもぼくはこの曲の作成者なので、DAW (作曲ソフト) の元データを持っています。元データにはメロディの情報が入っています。こいつをMIDIファイルに書き出す機能を利用して、出力したのがリポジトリの`drop.mid`です。この中から音が鳴る (ノートオン) する時間を単位は秒で取り出して、Luaから読めるように配列を含むLuaのコードとして出力するプログラムを書きます。MIDIファイルを読んでLuaコードを吐くだけなので言語はなんでもいいです。

じゃあCommon Lispで！！！ やってみました！！！！！

```lisp
;; (ql:quickload "midi")

(defun bpm (midi-tempo)
  (float (/ (* 60 1000 1000) midi-tempo)))

(defun to-sec (tick tempo division)
  (float (* tick (/ 60 (bpm tempo) division))))

(defun tempo-list (midi)
  (let ((tempo nil))
    (loop
      :for msg :in (elt (midi:midifile-tracks midi) 0)
      :when (typep msg 'midi:tempo-message)
      :do (push (midi:message-tempo msg) tempo))
    (nreverse tempo)))

(defun note-on-list (track)
  (loop
    :for msg :in track
    :when (typep msg 'midi:note-on-message)
    :collect (midi:message-time msg)))

(defun main (&rest argv)
  (declare (ignorable argv))
  (let* ((track-no (if (null (first argv))
                       0
                       (parse-integer (first argv))))
         (var-name (if (null (second argv))
                       "test"
                       (second argv)))
         (midi (midi:read-midi-file "drop.mid"))
         (division (midi:midifile-division midi))
         (tracks (midi:midifile-tracks midi))
         (tempo (first (tempo-list midi))))
    (format t "-- track = ~a, bpm = ~a, division = ~a~%" track-no (bpm tempo) division)
    (format t "local ~a = {}~%" var-name)
    (loop
      :for n := 0 :then (incf n)
      :for time :in (note-on-list (elt tracks track-no))
      :do  (format t "~a[~a] = ~a -- <= ~a / ~a~%" var-name n (to-sec time tempo division) time tempo))
    (format t "return {noteOns = ~a}" var-name)))
```

ちなみにこれは[Roswell](https://github.com/roswell/roswell)スクリプトです。`ros init note-on-from-midi`してできたファイルの一部を載せています。対象MIDIファイル名は固定(`./drop.mid`)で、使い方は `./note-on-from-midi.ros TRACK_NUMBER [VARNAME]`です。実際に `./note-on-from-midi.ros 0 track3NoteOn > track0.lua` してみた結果のファイルは[リポジトリの`track0.lua`](https://github.com/t-sin/love-sketches/blob/master/2021-10-26_drop/track0.lua)です。

MIDIファイルから情報を取り出すときの注意点としては以下が挙げられます:

- MIDIファイルのテンポは**BPMではなく**、**四分音符を何マイクロ秒とするか**であること
    - MIDIデータは楽器に食わせることがあるので、BPMだと浮動小数点数演算が必要だったりでたいへんなため
- MIDIファイル内の時間は、tickとtempoだけでなく、分解能 (division; 四分音符を何tickで表すか) も考慮する必要がある
- テンポ情報は0番目のトラックにノートオン等の情報に紛れて置かれる
    - 必要なら事前にトラック0だけ走査しておく必要あり

といったところでしょうか。

時間を計算するときは、BPM一定の曲ならば`tick * division * bpm` (bpmはよしなに計算してね) で算出できます。今回使用する『drop』はBPM一定の曲なのでこれでよいです。もしBPMが一定でない曲の場合は、その時のBPMを見つつ時間的前方から積算していかなければなりません。BPMは音符とは関係ないところで変わることがあるので注意が必要です。

このようにして、各トラックのノートオン (音の鳴り始める時間) のリストを6つ手にしました。あとは、ゲームループ内で再生開始時からの時間を測っておき、ノートオンリストの時間を越えたら丸を発生させればよいです。

## 映像のほうをつくる

ここからはLuaのコードでやっていきます。ちなみにコードはこちら

<https://github.com/t-sin/love-sketches/blob/master/2021-10-26_drop/main.lua>

で、完成品はこちら

<iframe width="560" height="315" src="https://www.youtube.com/embed/PBlCZ3PkLCM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

です。

コードのほうは描画のパラメータのマジックナンバーがてんこ盛りですが、そこから目を背ければまあ素直な、やってること相応のシンプルな実装になっていると思います。

映像は、丸が6つ描画され (2つは真ん中の同じ位置に重なっている) 、4つは公転運動をしています。さみしいので背景にも薄く波紋をだしておきました。`a`キーを押すと曲が流れはじめ、曲の各パートに対応する丸から、音の鳴り始めのときに波紋が放たれます。リズムの基礎をつくってそうなベース音のパートと「しゅわぁぁぁ」みたいな音のパートを真ん中に配置して、波紋を大きめにしています。最初位置をランダムにして波紋を発生していたら、いつ波紋が発生したかわからなくて曲との同期感がまったく得られなかったので、常に見えている動くオブジェクトから波紋を発しています。

## 感想

これくらいなら半日がんばればできるようです。ただ『Rez』にはまだまだ程遠いですね。まず映像を考えてつくるセンスのほうは、はじめたばかりなのでこれからの研鑽に期待しましょう。でももうちょっと、オブジェクトがいっぱいエモく動いていて、なんかブチあがる感じになっててほしい。たくさんのパーティクルが拍子に合わせてピカピカするとか。こんなふうに。

<iframe width="560" height="315" src="https://www.youtube.com/embed/cGiDf-KKTnw" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

音楽をアンビエントにしたのはよかったと思っています。エモみも多少あったかもです。しかし曲自体に盛り上りがあまりないし、映像のほうもあまり盛り上げポイントはなく淡々としているので、そういう工夫を次回はしたいです。映像に合わせることを考えながら曲をつくる、とかそういうのが必要そう。

音楽や映像、プログラムを、実験を完了させられるよう「至極簡単に！！」を旨としたので、まあこんなところでしょう。プログラムのほうでも、パーティクルシステムだったり、入力に対応させたり、とできることはあると思っています。

**t-sin先生の次回作にご期待ください！！**

## 余談

いままでtwitterとかYouTubeとかのリンクをURL直書きしてたんですが、埋め込み用リンクをつかえば静的サイトで楽に見やすく表示できますね。学び。
