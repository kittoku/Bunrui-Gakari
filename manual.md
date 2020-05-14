## マニュアルの注意
* 本マニュアルはシステム担当者向けに作成しています
* 本マニュアルで『ファイル』と呼称する場合，小分類(行政文書ファイル)ではなく小分類に入っている
.pdfや.doc等のファイルのことを指します
* フォルダとディレクトリはほぼ同じ意味ですが，前者は複数のファイルをまとめているもの，
後者は階層構造上のある位置という側面を筆者は意識しています
* 本スクリプトでは設定ファイルのフォーマットとしてXMLを採用しています．必要なXMLの知識は
[Wikipediaの記事](https://ja.wikipedia.org/wiki/Extensible_Markup_Language#XML%E3%81%AE%E6%A7%8B%E6%96%87%E3%81%A8%E6%95%B4%E5%BD%A2%E5%BC%8FXML%E6%96%87%E6%9B%B8)
で十分です

## ダウンロード

最新のスクリプトは[こちら](https://github.com/kittoku/Bunrui-Gakari/archive/v0.0.2.zip)からダウンロードできます．
過去のバージョンが欲しい場合は[Releases](https://github.com/kittoku/Bunrui-Gakari/releases)からそれぞれのSource code(zip)をダウンロードしてください．
本スクリプトはWindowsに標準搭載されているPowerShellを用いて動作するので他のソフトウェアは必要ありません．

## 動作に必要なファイル/フォルダ

* ライブラリ: 本スクリプトが使うモジュールが入っているフォルダです
* 保存場所: 行政文書が保存されるディレクトリです
* ポスト: 登録したいファイルを入れたり，
スクリプトが出力するファイルが届けられるフォルダです
* 分類.xml: 分類の階層構造が保存されるXMLファイルです
* 設定.xml: 上記4ヶ所のパスが保存されるXMLファイルです
* 分類係.ps1: これをダブルクリックすると本スクリプトが起動します

[TIPS]
* 設定.xmlと分類係.ps1は必ず同じディレクトリに入れてください
* 設定.xml以外のファイル/フォルダは適切にパスを指定されれば自由に命名可能です

## 設定.xml

設定例は[こちら](設定.xml)です．ライブラリ/保存場所/ポスト/分類設定それぞれの要素の内容にパスを設定してしてください．
相対パスと絶対パスのいずれでも動作しますが，ポスト以外は絶対パスを用いることをおすすめします

[TIPS]
* 例えばポスト以外のパスに共有サーバー上の場所を指定すれば，
一般の職員には[分類係.ps1/設定.xml/ポスト]の3つを配布するだけで事足ります

## 分類.xml

設定例は[こちら](example/分類.xml)です．分類.xmlは以下3種類の要素で構成されています

* 分類備考: それぞれの小分類に付与される備考です．保存期間や起算日に関する情報を含みます．
* ファイル備考: それぞれのファイルに付与される備考です．
* 分類: 大分類-中分類-小分類の木構造が表現された要素です．

### 分類要素のルール

* 大分類(中分類)は少なくとも1つの中分類(小分類)を含む必要があります
* すべての分類に属性[名称/コード]が必要です．小分類にはさらに属性[備考/頻度]が必要です．
* 属性[備考]に設定される文字列は分類備考で事前に定義される必要があります
* 属性[頻度]には[毎年度/不定期]のいずれかが設定可能です
* 属性[頻度]が毎年度の場合，さらに属性[書式]が必要です．属性[書式]には[前置/後置/区切]のいずれかが設定可能です．
* コードには半角英数文字のみ使用可能です．またコードの長さはそれぞれの階層で一致させる必要があります．
* それぞれの階層ではコードまたは名称が重複した要素を登録できません．ただし小分類は備考が異なれば同一の名称の要素を登録できます．

分類.xmlが不適切に設定された場合，スクリプトを起動した際にエラーが起こります

## 各タスクの詳細(仕様)

### ファイルの登録

* 登録したいファイルはタスクの選択前にポストフォルダに入れてください
* 名前の先頭が_(アンダースコア)のファイルはシステムファイルとして無視されます
* 登録されたファイルはポストから削除(移動)されます
* フォルダを登録することも可能です
* 現在，平成23年4月1日以前の作成日時を指定することはできません
* 作成日時が平成31年4月のファイルは令和元年度作成のものとして扱われます
* 同一作成日時かつ同一名称のファイルが同じ小分類に既に登録されていた場合，新しいファイルの作成日時にはリビジョンが追加されます  
例: "20190401_契約書.doc"が登録されている小分類に，
ファイル備考[課長説明]の"契約書.doc"を登録するとファイルは"20190401_1 課長説明_契約書.doc"と命名されます
* 小分類の属性[書式]で小分類命名時の年号の付与方法を選択できます．  
例: 令和元年度分の小分類[原義綴]が作成される場合  
前置　→　"令和元年度原義綴"  
後置　→　"原義綴（令和元年度）"  
区切　→　"令和元年度　原義綴"

### ファイル一覧/分類一覧の出力
* 一覧のCSVファイルはポストに出力されます
* CSVはシステムのデフォルトエンコードで出力されます
* ファイル一覧に含まれる小分類の作成日時は各年度の4月1日と認識されます
* 正しく命名されていないファイルが小分類に含まれている場合ファイル備考[違反]として一覧に記載されます
* 逆に，分類.xmlで設定されていないファイル備考を用いたファイルが正しく命名されていた場合は違反にはなりません

### ショートカットの作成
* ショートカットはポストに出力されます
* ファイルや小分類が記載されたCSVファイルをスクリプトに読み込ませることで
当該ファイル(小分類)へのショートカットをポストに出力できます
* CSVファイルにはファイル一覧の出力で取得したCSVファイルを編集した(ショートカットを作らないレコードの行を削除した)ものを使用してください

### ファイル/小分類の削除
* ショートカットの作成と同じ要領で，読み込ませたCSVに含まれるファイルや小分類を一括削除できます
* 削除(廃棄)は関連法規に基づき慎重に行われる必要があるため，タスク選択の画面では選択肢が表示されません
* 削除を行う場合はタスク選択の画面で"DELETE"と入力してください

## その他
* PowerShellの実行ポリシーが厳しい場合，スクリプトが起動できません．その場合は[こちらのページ](https://www.atmarkit.co.jp/ait/articles/0805/16/news139.html)
等を参考にして実行ポリシーをRemoteSignedかそれより緩いものに変更してください．
* 動作確認はPowerShellのバージョン4(Windows8.1標準搭載)とバージョン5(Windows10標準搭載)で行っています
* おかしい動作やわかりにくい所をissueで報告していただければスクリプトとマニュアルの改善に非常役に立ちます