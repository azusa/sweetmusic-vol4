\lhead[]{}
\rhead[]{}
\chead[GebとSpockではじめるエンドツーエンドテスト]{GebとSpockによるエンドツーエンドテスト}

# GebとSpockではじめるエンドツーエンドテスト

本稿では、プログラミング言語 Apache Groovy ^[以下Groovy] ^[[http://groovy-lang.org/](http://groovy-lang.org/)]を使用したSelenium WebDriver拡張のブラウザー自動化ツールであるGebと、
同じくGroovyを用いるSpockを使用した、エンドツーエンドのテストについて述べます。

## アジャイルテストの四象限とエンドツーエンドテスト

自動化されたユニットテストに代表される、開発者によるプログラムに対して行なうテスト以外にも、
ソフトウェアテストには複数の軸と象限が存在します。
セキュリティー、パフォーマンス、ユーザビリティーなどの非機能要件に対するテスト、
システムの完成度を高めるための探索的テストなど、前章で述べたようなシステムの受け入れ要件を
確認するためのテストなどです。

Lisa Crispin氏とJanet Gregory氏は「Agile Testing」[@Crispin2009]^[邦訳「実践アジャイルテスト」]の中で、
その軸を「チームを支援するテストと、製品を評価するテスト」「ビジネス面のテストと、技術面のテスト」に
分類して、「アジャイルテストの四象限」としています。

Gregory氏とCrispin氏は更にその後、「More Agile Testing」[@Gregory2015]の中でMichael Hüttermann氏
の議論[@Huttermann2011]を取り込む形で、「アジャイルテストの四象限」について稿を改めています。 

Hüttermann氏は、アジャイル開発の中で、テストを通じてステークホルダーが協調するポイントとして、
以下の3つのポイントをあげています。

- Outside-in
- Barrier-free
- Collaborative

一つ目の「Outside-in」は、アプリケーションの望ましい振る舞いを規定するビジネス要求から、トップダウンでソフトウェア開発に切り込んでいくことを示しています。

二つ目の「Barrier-free」は、ここまで述べてきたBDDスタイルの開発によって、ビジネス面からテクノロジーによった側面まで、シームレスにテストによって開発が駆動されることを示しています。

三つ目の「Collabrative」は、多様なステークホルダーがユビキタス言語として記述されたシナリオを通じて、ソフトウェア開発の中で協調することを示しています。

「More Agile Testing」では、この視野を取り込んだ上で、四象限の中での「チームを支援するテスト」という
軸を、「開発の手引きとなるテスト」と改めています。

![アジャイルテストの四象限](src/img/agiletesting-2.png){#fig:040_a_image}

本稿では、[@fig:040_a_image]の中で、主に左上の象限に位置する、開発プロセスに於いてビジネス面の
テストの自動化についてフォーカスします。
その上で、Groovyによって記述されたブラウザー自動化ツールであるGebと、
同じくGroovyによって記述されたテスティングフレームワークである
Spockによるエンドツーエンドの手法について述べます。

「xUnit」と総称されるテスティングフレームワークによって書かれるテストは、
システムの最小構成単位であるメソッドや関数に対してのテストを最も小さい粒度としています。
テストの粒度を大きい範囲にすることもできますが、
メソッドや関数の集合体としてのAPIのエンドポイントを単体にないし複数回シナリオとして呼び出すのが
最も大きな範囲となります。

これに対しエンドツーエンドのテストは、ユーザーが実際にシステムに呼び出す時の操作を
模倣してテストを行います。本稿で取り上げるGebでは、クロスブラウザーの
Webブラウザー操作自動化APIであるSelenium WebDriverを使用して、
Webブラウザー上でのユーザーの操作に対してテストを行います。

## GebとSpockによるエンドツーエンドテスト

Gebは、Luke Daley氏、Marcin Erdmann氏、Chris Prior氏が中心となって開発を進めている
オープンソースソフトウェアで、[http://gebish.org/](http://gebish.org/)で公開されています。
ライセンスはApache License Version 2.0で、本稿の執筆時での最新バージョンは1.1.です。

Gebは、Groovyの言語機能を生かした簡潔な記述と、
jQueryライクなDOMへアクセスするための式言語が特徴となっています。

Geb自体はその実装にテスティングフレームワークを含んでおらず、任意のテスティングフレームワークと
組み合わせて使えるようになっています。Gebのドキュメント^[[http://www.gebish.org/manual/current/](http://www.gebish.org/manual/current/)]では、組み合わせの例としてSpock,JUnit,
TestNGおよびCucumber-JVMが示されています。

本稿では、例示に使うテスティングフレームワークとしてSpockを使用します。
SpockとGebが同じGroovyで記述されていることによる親和性の高さや、
BDD(Behavior Driven Development)スタイルでシナリオを記述することが
エンドツーエンドのテストのシナリオを記述する上で使い勝手がよいためです。[@lst:040_code1]

```{#lst:040_code1 caption="Spockによる記述"}
    def "Book of Gebの現行バージョンが表示できる"() {
        when: "Gebのホームページを表示する"
        to GebishOrgHomePage

        and: "マニュアルのメニューを開く"
        manualsMenu.open()

        then: "currentのリンクがcurrentではじまっている"
        manualsMenu.links[0].text().startsWith("current")

        when: "リンクをクリックする"
        manualsMenu.links[0].click()

        then: "The Book Of Gebのページが表示される"
        at TheBookOfGebPage
    }
```

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

Gebのページオブジェクトでは`geb.page.Page`クラスを継承して
ページオブジェクトを記述します。その際にstaticな`at`クロージャーの
中に、ページが含むべきDOMの要素の条件を記述することで、
テスト内の画面遷移が正しいかを検証します。[@lst:040_code2] 

```{#lst:040_code2 caption="ページオブジェクト"}
class GebishOrgHomePage extends Page {

    static at = { title == "Geb - Very Groovy Browser Automation" }

    static content = {
        manualsMenu { module(ManualsMenuModule) }
    }
}
```

### ページオブジェクト上でのDOM要素の特定について

Selenium WebDriverによってテストを記述する上でのセオリーとして、テストが
参照するDOM上の要素に一意になるhtmlの`id`要素を振って、テストからDOMを
参照する際は`id`要素を使ってアクセスするというものがあります。

しかし近年のWebアプリケーション開発では、シングルページアプリケーション(SPA)の場合
`id`要素を一意にするにはアプリケーション全体で`id`要素を一意にする必要があるという
問題がありました。

さらにWebアプリケーションのユーザーインターフェースがリッチになる中でアプリケーションが動的に
DOMを生成することがありふれたものとなってきました。すると、html内にhtmlの
要素として`id`を記述すること自体がアプリケーションの開発スタイルと
そぐわないものになってきました。

このため、Gebによるエンドツーエンドのテストでページオブジェクトを
使用する場合は、
ページオブジェクトのプロパティー上で、この次に述べる`$`を使用したjQueryライクの
マッチャー等を使用してDOMの要素を特定します。
そしてテストからはページオブジェクトのプロパティー経由でDOMにアクセスすることで
テストからDOMの要素を隠蔽するという手順を踏みます。

## $関数

Gebでは、テスト内でWebDriverを通じてブラウザーの要素にアクセスするにあたって、
jQueryに類似した`$`というメソッドを起点としてオブジェクトを取得します。

`$`メソッドはGebのテストケース内で以下のようなシグネチャを伴って呼び出します。

 ```
$(cssセレクター, インデックスまたは範囲, 属性または文字列のマッチャー)
 ```

例としては以下の通りです。

 ```
$("h1", 2, class: "heading")
 ```

この`$`というメソッドが返すオブジェクトはGroovyのシンタックスとしては、
GroovyのmethodMissing ^[[http://groovy-lang.org/metaprogramming.html#_methodmissing](http://groovy-lang.org/metaprogramming.html#_methodmissing)]という仕組みを使って
`geb.Browser`クラス ^[[https://github.com/geb/geb/blame/master/module/geb-core/src/main/groovy/geb/Browser.groovy](https://github.com/geb/geb/blame/master/module/geb-core/src/main/groovy/geb/Browser.groovy)]
を経由して呼び出される`geb.navigator.Navigator` ^[[http://www.gebish.org/manual/current/api/geb/navigator/Navigator.html](http://www.gebish.org/manual/current/api/geb/navigator/Navigator.html)]クラスのオブジェクトです。

## GebとmethodMissing

Gebのテストケース内ではこのmethodMissingの仕組みを使って、

```
browser.to(GebishOrgHomePage)
```
という記述を、

```
to GebishOrgHomePage
```

のように、簡略化して記述することが可能です。

methodMissingの仕組みはIDE(統合開発環境)上でのコード補完や定義先ジャンプなどの
インテリジェンスな機能と相性が悪く、
JavaプログラマーにとってGebを敬遠する要因の一つとなっていました。

Javaを主なターゲットとするIDEであるIntelliJ IDEAでは、Groovy向けのサポートを通じて、
Gebのシナリオを記述する際に、以下のような機能を使うことができます。^[[http://www.gebish.org/manual/current/#intellij-idea-support](http://www.gebish.org/manual/current/#intellij-idea-support)]

- `geb.spock.GebSpec`を継承したクラスでの`to`や`at`などの暗黙メソッドの解釈
- `Page`および`Module`で定義したContent DSLの内容の、コード補完のサポート
- `at {}`ならびに`content {}`内でのコード補完

## 非同期処理

Gebでは非同期処理の記述を行うには、要素の出現判定する処理のブロックを `waitFor{ 条件 }`で囲みます。タイムアウトは`GebConfig.groovy`の`waiting`ブロックのクロージャーで`timeout`プロパティーを設定します。

また、ページオブジェクトを使用している場合は、

` toggle(wait:true) { $("div.menu a.manuals") }`

のようにコンテントに`wait:true`を指定することで、ページオブジェクトを
操作する際に要素の出現を待機することが出来るようになります。[@PoohSunny2014]

## 設定の切り替え

Gebでは、クラスパス上の`GebConfig.groovy`上にテストを実行する上での
各種設定を記述します。

環境によって設定値を切り替える場合は、Gebでは、実行時にシステムプロパティー`geb.env`を設定することにより、`GebConfig.groovy`の`environments`ブロックで設定値の切り替えを行うことができます。 ^[[https://github.com/geb/geb-example-gradle/blob/master/src/test/resources/GebConfig.groovy](https://github.com/geb/geb-example-gradle/blob/master/src/test/resources/GebConfig.groovy)] 

Gebの実行時に`geb.env`を切り替える場合は、Gradleの起動オプションでフラグ値を指定し、
`build.gralle`内でフラグ値をシステムプロパティー`geb.env`に設定します。

Gradleでは`gradle.properties`ないしコマンド実行時の`-P`オプションでプロパティーを
指定するのが一般的です。[@lst:040_code3a]

```{#lst:040_code3a caption="環境による設定値の切り替え"}
gradlew test -Ptarget=heroku
```

次の例では、`build.gradle`内で`geb.env`に対象となるサイトのURLを指定しています。[@lst:040_code3]

```{#lst:040_code3 caption="環境による設定値の切り替え"}
environments {
	gebishorg {
		baseUrl = "http://gebish.org"
	}
	heroku {
		baseUrl = "http://gebish.herokuapp.com"
	}
}
```

## クロスブラウザー

Gebでは、
使用するWebDriverを指定する上で`GebConfig.groovy`内の`driver`という変数に

- WebDriverの実装クラス名を指す文字列
- WebDriverのインスタンスを返すクロージャー

のどちらかを示すという仕様があり^[[http://www.gebish.org/manual/current/#driver-class-name](http://www.gebish.org/manual/current/#driver-class-name)]、それぞれのブロック内でその処理を行っています。

Gebの公式サンプルである`geb-example-gradle` ^[[https://github.com/geb/geb-example-gradle](https://github.com/geb/geb-example-gradle)]では、システムプロパティー`geb.env`を使用するブラウザーの
切り替えに使用していますが、例えば開発環境とステージング環境等の複数環境でGebによる
テストを行う際には、`geb.env`はドライバーの指定と実行環境の指定どちらかにしか用いることはできません。

この場合、「開発環境とステージング環境」のような対象となる環境の切り替えにシステム
プロパティー`geb.env`を使用し、ブラウザーの切り替えには別の手段を用いて切り替えを
行った方がスマートであると筆者は考えます。


システムプロパティー`geb.env`を用いないでテスト実行時に使用するブラウザーを切り替えるには、
`build.gradle`等のビルドスクリプトから別のシステムプロパティーを使って
フラグを渡し、`GebConfig.groovy`内でこのシステムプロパティーを参照してブラウザー
を切り替えるという手順を踏みます。


WebDriverはW3CでDriverのインターフェースと仕様が規定されており^[[https://seleniumhq.github.io/selenium/docs/api/java/org/openqa/selenium/WebDriver.html](https://seleniumhq.github.io/selenium/docs/api/java/org/openqa/selenium/WebDriver.html)]、
それに対して、各ブラウザーの開発元がDriverの実装を提供するという枠組みになっています。
`geb-example-gradle`ではChromeとFirefoxでの実装を指定する例が提供されて
います。

この際、ブラウザーによってはブラウザーとの間とのブリッジとなるネイティブランタイムを
配置する必要があります。その場合、ランタイムのパスはWebDriverの指定とは別のシステムプロパティーで指定します。
次に各ブラウザーごとの指定方法を示します。

### Chrome

Chromeでは`chromedriver.exe`ないし`chromedriver`への絶対パスをシステムプロパティー
`webdriver.chrome.driver`で
指定します。

### Headless Chrome

Chrome59より実装されたヘッドレス機能をGebで使用するには、`GebConfig.groovy`のdriverを
指定するクロージャー内で  
`org.openqa.selenium.chrome.ChromeOptions`に`headless`オプションを指定します。[@lst:040_code4]

```{#lst:040_code4 caption="Chrome ヘッドレス機能の使用"}
case "chromeHeadless" :
	setUpChromeDriver(BUILD_DIR)
	driver = {
		ChromeOptions o = new ChromeOptions()
		o.addArguments('headless')
		new ChromeDriver(o)
	}
	break
(略)
private void setUpChromeDriver(String buildDir) {
	def chromedriverFilename =
			SystemUtils.IS_OS_WINDOWS ?
					"chromedriver.exe" : "chromedriver"
	System.setProperty "webdriver.chrome.driver",
			"$buildDir/webdriver/chromedriver/$chromedriverFilename"
}
```	

### Firefox

Firefoxでは`geckodriver.exe`ないし`geckodriver`への絶対パスをシステムプロパティー`webdriver.gecko.driver`で指定します。

### Internet Explorer(IE)

Internet Explorer 11(IE11)では`IEDriverServer.exe`への絶対パスをシステムプロパティー
`webdriver.ie.driver`で指定します。また、`InternetExplorerDriver`ではInternetExploerの「保護モード」の設定を、セキュリティー設定の各ゾーンで同一に
する必要があるという仕様があるため、保護モードの設定を必要に応じて変更します。[@fig:040_c_image]

![IE11の保護モードの設定](src/img/ie.png){#fig:040_c_image}

### Microsoft Edge

Microsoft Edge ^[以下Edge] では`MicrosoftWebDriver.exe`へのパスをシステムプロパティー`webdriver.edge.driver`に設定します。

本章のサンプル^[[https://github.com/azusa/techbookfest3-geb](https://github.com/azusa/techbookfest3-geb)]内では、ChromeとFirefox向けのDriverのダウンロードならびに展開ははGraldeのテスト実行時に
前処理として行うようにしています。IDEでのセットアップのためにダウンロードを単独で行う場合は
build.gradle内の`unzipGeckoDriver`タスクないし`unzipChromeDriver`タスクを単独で実行します。

IE11ならびにEdge向けのドライバーはgitレポジトリー内に`git-lfs`を使用して格納しています。

また、開発者の端末はWindowsであり、継続的インテグレーション(CI)のサーバー上では
Linuxで実行されるように、複数の端末上でテストが実行される場合、スクリプト内で実行
されるOSの判定を行い、適切な設定を行います。

OSの判定は、Gradleのビルドスクリプト内ではGradleに組み込まれている  
`org.apache.tools.ant.taskdefs.condition.Os`クラスで行います。
`GebConfig.groovy`内で判定を行う場合はサードパーティーのライブラリーであるCommons Langの
`org.apache.commons.lang3.SystemUtils`クラスを用いてOSの判定を行います。

テスト実行のオプション指定でDriverの実装を切り替えることにより、単一の
アプリケーションに対してクロスブラウザーでのエンドツーエンドのテストを
行うことが可能です。
ですが、例えばInternetExploerやEdgeのDriver実装は、非同期処理を伴わない
画面遷移であっても、`GebConfig.groovy`の`waiting`ブロックによる
タイムアウトの設定を長めにとらないとDOMの要素を適切に取得できないなどの
問題があります。このようなテスト実行の上で考慮すべき問題はブラウザーごとに
存在します。

UIの単体テストでなく、アプリケーションのシナリオを通じてユースケースを
実現しているかの受け入れてとしてエンドツーエンドのテストを行うのであれば、
アプリケーションが動作対象とするブラウザーの中からエンドツーエンドの
テストの対象とするブラウザーをピックアップすることが望ましいです。
そのテスト運用が安定してから、さらなる品質向上を目指してクロスブラウザー
でのエンドツーエンドのテストに取り組むのが良いでしょう。

## レポーティング

SpockではRenato Athaydes氏が開発しているspock-reports^[[https://github.com/renatoathaydes/spock-reports](https://github.com/renatoathaydes/spock-reports)]という拡張を
使用することにより、BDDのスタイルに即した形でのレポート表示を行うことが可能です。[@fig:040_b_image]

![spock-reportsによるレポート表示](src/img/spock-report.png){#fig:040_b_image}


SpockでGebのテストを記述する際、Feature Method内の`given`-`when`-`then`内に
シナリオを記述することにより、レポートで見た際にテストが
行っていることをわかりやすく記述させることができます。[@lst:040_code5a]

```{#lst:040_code5a caption="Spock内でのシナリオ記述"}
    then: "currentのリンクがcurrentではじまっている"
    manualsMenu.links[0].text().startsWith("current")
```

Gebでspock-reportsを使用するには、build.gradleで`com.athaydes:spock-repots`を依存性に追加します。

この際、Gebが依存するSpockのバージョンが`1.0-groovy-2.4`であり
spock-reportsが依存するのは`1.1-groovy-2.4`であるため、
上記を共存させるための`build.gradle`は次の通りとなります。[@lst:040_code5] ^[本稿の執筆中にリリースされたGeb 2.0-rc-1では、Gebが依存するSpockが1.1-groovy-2.4に変更されました。]

```{#lst:040_code5 caption="spock-reportsを使用するbuild.gradle"}
    testCompile (group: 'com.athaydes', name: 'spock-reports',
     version: '1.3.2'){
        transitive = false
    }
    testCompile 'org.slf4j:slf4j-api:1.7.13'
    testCompile 'org.slf4j:slf4j-simple:1.7.13'
    testCompile ("org.gebish:geb-spock:$gebVersion") {
        exclude group: "org.spockframework"
    }
    testCompile (group: 'org.spockframework', 
    name: 'spock-core', version: '1.1-groovy-2.4') {
        exclude group: "org.codehaus.groovy"
    }

```

spock-reportsはレポートの作成時にGradleを起動するJVMのデフォルトエンコーディングを
参照しており、レポート表示時の文字化けを回避するにはデフォルトエンコーディングの指定が
UTF-8である必要があります。この指定のためには、Gradleのラッパースクリプトである
`gradlew`(UNIX系)ないし`gradlew.bat`(Windows)内で環境変数`DEFAULT_JVM_OPTS`に
`-Dfile.encoding=UTF-8`を記述します。

また、Gebでは`geb.spock.GebReportingSpec`を継承することで、テストの実行時に
自動でスクリーンショットを取得することができます。取得したスクリーンショットは
システムプロパティー`geb.build.reportsDir`で指定したディレクトリーに
作成されます。


## Gebのリソース

Gebは公式の英語によるドキュメント^[[http://www.gebish.org/manual/current/](http://www.gebish.org/manual/current/)]が充実しており、Gebを活用するにあたっては
まずこちらを参照するとよいでしょう。

またGebのソースコード^[[https://github.com/geb/geb](https://github.com/geb/geb)]は
Groovyのソースコードリーディングの題材として優れているので、
GebのAPI呼び出しからメタプログラミングやAST変換がどのように動いているのか
興味をお持ちでしたらソースコードを眺めてみるのもよいでしょう。

日本語のリソースとしては、「Selenium実践入門」[@Ito2016]が中で一章を割いてGebについて記述しています。WEB+DB PRESS VOL.85の「GebによるスマートなE2Eテスト」[@Sato2015]もGebについて触れています。

Web上のリソースとしては、「Groovy製のSeleniumラッパーライブラリ「Geb」で、可読性の高いテストを書いてみよう」^[[https://codezine.jp/article/detail/10456](https://codezine.jp/article/detail/10456)] [@Takahashi2017] があります。

また2016年12月に開かれた「Geb Advent Calendar 2016」^[[https://qiita.com/advent-calendar/2016/geb](https://qiita.com/advent-calendar/2016/geb)] にも日本語でのGebに関するエントリーが集積されています。

Gebのメイン開発者であるMarcin Erdmann氏はカンファレンスに登壇した際に
GebのContributorを全員紹介するなど^[筆者はGebのContributorです。] ^[[https://youtu.be/yKFHmLYCfn0?t=2m9s](https://youtu.be/yKFHmLYCfn0?t=2m9s)] コミュニティーに対して友好的であり、
Gebのコミュニティーはプルリクエストなどの要望にも丁寧に対応してくれます。

GebによるエンドツーエンドのテストはSpockと組み合わせることで、
BDDスタイルのテスト記述やレポート出力など、上位のテストレベルと
してのエンドツーエンドテストに求められる機能を備えることができます。

また、GebとSpockの組み合わせにより、GroovyのJavaライクな軽量の
スクリプト記述を生かすことができます。本稿がみなさんの
Gebによるテスト記述のきっかけになれば幸いです。
