\lhead[]{}
\rhead[]{}
\chead[GebとSpockではじめるエンドツーエンドテスト]{GebとSpockによるエンドツーエンドテスト}

# GebとSpockではじめるエンドツーエンドテスト

本稿では、Groovyを使用したSelenium WebDriver拡張のブラウザー自動化ツールであるGebと、
同じくGroovyを用いるSpockを使用した、エンドツーエンドのテストについて述べます。

## アジャイルテストの四象限

自動化されたユニットテストに代表される、開発者によるプログラムに対して行なうテスト以外にも、
ソフトウェアテストには複数の軸と象限が存在します。
セキュリティー、パフォーマンス、ユーザビリティーなどの非機能要件に対するテスト、
システムの完成度を高めるための探索的テストなど、前章で述べたようなシステムの受け入れ要件を
確認するためのテストなどです。

Lisa Crisping氏とJanet Gregory氏は「Agile Testing」[@Crispin2009]^[邦訳「実践アジャイルテスト」]の中で、
その軸を「チームを支援するテストと、製品を評価するテスト」「ビジネス面のテストと、技術面のテスト」に
分類して、「アジャイルテストの四象限」としています。

Gregory氏とCrisping氏は更にその後、「More Agile Testing」[@Gregory2015]の中でMichael Hüttermann氏
の議論[@Huttermann2011]を取り込む形で、「アジャイルテストの四象限」について稿を改めています。 [@fig:030_a_image]

Hüttermann氏は、アジャイル開発の中で、テストを通じてステークホルダーが協調するポイントとして、
以下の3つのポイントをあげています。

- Outside-in
- Barrier-free
- Collaborative

「More Agile Testing」では、この視野を取り込んだ上で、四象限の中での「チームを支援するテスト」という
軸を、「開発の手引きとなるテスト」と改めています。

![アジャイルテストの四象限](src/img/agiletesting.png){#fig:030_a_image}

本稿では、[@fig:030_a_image]の中で、主に左上の象限に位置する、開発プロセスに於いてビジネス面の
テストの自動化についてフォーカスします。
その上で、プログラミング言語Apache Groovy ^[以下Groovy]^[[http://groovy-lang.org/](http://groovy-lang.org/)]によって記述されたブラウザー自動化ツールであるGebと、
同じくGroovyによって記述されたテスティングフレームワークである
Spockによるエンドツーエンドの手法について述べます。

## エンドツーエンドテスト

「xUnit」と総称されるテスティングフレームワークによって書かれてるテストは、
システムの最小構成単位であるメソッドや関数に対してのテストを最も小さい粒度としています。
テストの粒度を大きい範囲にすることもできますが、
メソッドや関数の集合体としてのAPIのエンドポイントを単体にないし複数回シナリオとして呼び出すのが
最も大きな範囲となります。

これに対しエンドツーエンドのテストは、ユーザーが実際にシステムに呼び出す時の操作を
模倣してテストを行います。本稿で取り上げるGebでは、クロスブラウザーの
Webブラウザー操作自動化APIであるSelenium WebDriverを使用して、
Webブラウザー上でのユーザーの操作に対してテストを行います。

## Geb

Gebは、Luke Daley氏、Marcin Erdmann氏、Chris Prior氏が中心となって開発を進めている
オープンソースソフトウェアで、[http://gebish.org/](http://gebish.org/)で公開されています。
ライセンスはApache License Version 2.0です。
Gebは、Groovyの言語機能を生かした簡潔な記述と、
jQueryライクなDOMへアクセスするための式言語が特徴となっています。

## GebとSpockによるエンドツーエンドテスト

Geb自体はその実装にテスティングフレームワークを含んでおらず、任意のテスティングフレームワークと
組み合わせて使えるようになっています。Gebのドキュメント^[[http://www.gebish.org/manual/current/](http://www.gebish.org/manual/current/)]では、組み合わせの例としてSpock,JUnit,
TestNGおよびCucumber-JVMが示されています。

本稿では、例示に使うテスティングフレームワークとしてSpockを使用します。
SpockとGebが同じGroovyで記述されていることによる親和性の高さや、
BDDスタイルでシナリオを記述することがエンドツーエンドのテストの
シナリオを記述する上で使い勝手がよいためです。

## ページオブジェクト

ページオブジェクトとは、Selenium WebDriverを使用する際のテスト記述の
パターンの一つです。Selenium WebDriverのドキュメントでは、
ページオブジェクトの特徴が以下のようにまとめられています。^[[https://github.com/SeleniumHQ/selenium/wiki/PageObjects](https://github.com/SeleniumHQ/selenium/wiki/PageObjects)]

- publicメソッドは、ページが提供するサービスを表す
- ページの内部構造を露出しないようつとめる
- 原則として(ページオブジェクト内で)アサーションを行わない
- メソッドは他のページオブジェクトを返す
- 一つのページ全体を(一つの)ページオブジェクトで表す必要は無い
- 同じ操作が異なる結果となる場合は、異なるメソッドとしてモデル化する


## ページオブジェクト上でのDOM要素の特定について

Selenium WebDriverによってテストを記述する上でのセオリーとして、テストが
記述するDOM上の要素に一意になるhtmlの`id`要素を振って、テストからDOMを
参照する際は`id`要素を使ってアクセスするというものがあります。

しかし近年のWebアプリケーション開発では、シングルページアプリケーション(SPA)の場合
`id`要素を一意にするにはアプリケーション全体で`id`要素を一意にする必要があるという
問題がありました。

さらに近年のトレンドであるコンポーネント指向では、htmlとコンポーネント間の
マッピングに`id`を使用する場合があるため、この点でもエンドツーエンドのテストの
DOM要素のマッピングに`id`を使用することは嫌忌されつつあります。

このため、Gebによるエンドツーエンドのテストでページオブジェクトを使用する場合は、
ページオブジェクトのプロパティ上で、要素を特定するDOMのパスを記述し、
テストからはページオブジェクトのプロパティ経由でDOMにアクセスすることで
テストからDOMの要素を隠蔽するという手順を踏みます。

## $関数

Gebでは、テスト内でWebDriverwを通じてブラウザーの要素にアクセスするにあたって、
jQueryに類似した`$`というメソッドを起点としてオブジェクトを取得します。

`$`メソッドはGebのテストケース内で以下のようなシグネチャを伴って呼び出します。

 ```
$(cssセレクター, インデックスまたは範囲, 属性または文字列のマッチャー)
 ```

例としては以下の通りです。

 ```
$("h1", 2, class: "heading")
 ```

この`$`というメソッドが返すオブジェクトははGroovyのシンタックスとしては、
GroovyのmethodMissingという仕組みを使って`geb.Browser`クラス^[[https://github.com/geb/geb/blame/master/module/geb-core/src/main/groovy/geb/Browser.groovy](https://github.com/geb/geb/blame/master/module/geb-core/src/main/groovy/geb/Browser.groovy)]を経由して呼び出される`geb.navigator.Navigator`^[[http://www.gebish.org/manual/current/api/geb/navigator/Navigator.html](http://www.gebish.org/manual/current/api/geb/navigator/Navigator.html)]クラスのオブジェクトです。

また、Gebのテストケース内ではこのmethodMissingの仕組みを使って、

```
browser.to(GebishOrgHomePage)
```
という記述を、
```
to GebishOrgHomePage
```

のように、簡略化して記述することが可能です。

## 非同期処理

## 設定の切り替え

Gebでは、クラスパス上の`GebConfig.groovy`上にテストを実行する上での
各種設定を記述します。

環境によって設定値を切り替える場合は、Gebでは、実行時にシステムプロパティー`geb.env`を設定することにより、`GebConfig.groovy`の`environments`ブロックで設定値の切り替えを行うことができます。^[[https://github.com/geb/geb-example-gradle/blob/master/src/test/resources/GebConfig.groovy](https://github.com/geb/geb-example-gradle/blob/master/src/test/resources/GebConfig.groovy)]

```
environments {
	
	// run via “./gradlew chromeTest”
	// See: http://code.google.com/p/selenium/wiki/ChromeDriver
	chrome {
		driver = { new ChromeDriver() }
	}

	// run via “./gradlew chromeHeadlessTest”
	// See: http://code.google.com/p/selenium/wiki/ChromeDriver
	chromeHeadless {
		driver = {
			ChromeOptions o = new ChromeOptions()
			o.addArguments('headless')
			new ChromeDriver(o)
		}
	}
	
	// run via “./gradlew firefoxTest”
	// See: http://code.google.com/p/selenium/wiki/FirefoxDriver
	firefox {
		atCheckWaiting = 1

		driver = { new FirefoxDriver() }
	}

}

```

上記の例では、`build.gradle`内で`geb.env`にドライバーの種別を指定していますGebでは、
使用するWebDriverを指定するのに、`GebConfig.groovy`内の`driver`という変数に

- 文字列でWebDriverの実装クラスを指定する
- クロージャーでWebDriverのインスタンスを返す

という仕様があるため^[[http://www.gebish.org/manual/current/#driver-class-name](http://www.gebish.org/manual/current/#driver-class-name)]、それぞれのブロック内でその処理を行っています。

Gebの`geb-example-gradle`等では、システムプロパティー`geb.env`を使用するブラウザーの
切り替えに使用していますが、例えば開発環境とステージング環境等の複数環境でGebによる
テストを行う際には、`geb.env`はどちらか片方の用途にしか用いることはできません。

この場合、「開発環境とステージング環境」のような対象となる環境の切り替えにシステム
プロパティー`geb.env`を使用し、ブラウザーの切り替えには別の手段を用いて切り替えを
行った方がスマートであると筆者は考えます。

## クロスブラウザー

システムプロパティー`geb.env`を用いないでテスト実行時に使用するブラウザーを切り替えるには、`build.gradle`等のビルドスクリプトから別のシステムプロパティーを使って
フラグを渡し、`GebConfig.groovy`内でこのシステムプロパティーを参照してブラウザー
を切り替えるという手順を踏みます。

Gradleでは`gradle.properties`ないしコマンド実行時の`-P`オプションでプロパティーを
指定するのが一般的です。

WebDriverはW3CでDriverのインターフェースと仕様が規定されており^[[https://seleniumhq.github.io/selenium/docs/api/java/org/openqa/selenium/WebDriver.html](https://seleniumhq.github.io/selenium/docs/api/java/org/openqa/selenium/WebDriver.html)]、

それに対して、各ブラウザーがDriverの実装を提供するという枠組みになっています。
`geb-example-gradle`ではChromeとFirefoxでの実装例が提供されています。

Web

この際、ブラウザーによってはブラウザーとの間とのブリッジとなるネイティブランタイムを
配置する必要があります。

※いきなりクロスブラウザーはおすすめしない

## マルチステージ

先述した通り、Gebでは、実行時にシステムプロパティー`geb.env`を設定することにより、
`GebConfig.groovy`の`environments`ブロックで設定値の切り替えを行うことが
できます。これを使用した`GebConfig.groovy`の記述のサンプルは以下の通りと
なります。

## WebDriverでは

## レポーティング

## 録画

## テスト自動化ピラミッド

## Webアプリケーションにおけるエンドツーエンドテストの役割

Gebをフロントエンドの単体テストに使うのであれば、テストスイートは分けましょうね

## Gebのリソース

Gebは公式の英語によるドキュメントが充実しており、Gebを活用するにあたっては
まずこちらを参照するとよいでしょう。

日本語のリソースとしては、WEB+DB PRESS VOL.85の「GebによるスマートなE2Eテスト」[@Sato2015]が
あげられます。また2016年12月に開かれた「Geb Advent Calendar 2016」^[[https://qiita.com/advent-calendar/2016/geb](https://qiita.com/advent-calendar/2016/geb)] にも日本語でのGebに関するエントリーが集積されています。

- Gebのソースコード読みやすいし
- コミュニティーも親切だしhttps://youtu.be/yKFHmLYCfn0?t=2m9s

