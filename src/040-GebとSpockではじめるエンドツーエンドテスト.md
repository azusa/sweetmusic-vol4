\lhead[]{}
\rhead[]{}
\chead[GebとSpockではじめるエンドツーエンドテスト]{GebとSpockによるエンドツーエンドテスト}

# GebとSpockではじめるエンドツーエンドテスト

本稿では、Groovyを使用したSelenium WebDriver拡張のブラウザー自動化ツールであるGebと、
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
その上で、プログラミング言語Apache Groovy ^[以下Groovy] ^[[http://groovy-lang.org/](http://groovy-lang.org/)]によって記述されたブラウザー自動化ツールであるGebと、
同じくGroovyによって記述されたテスティングフレームワークである
Spockによるエンドツーエンドの手法について述べます。

「xUnit」と総称されるテスティングフレームワークによって書かれてるテストは、
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
ライセンスはApache License Version 2.0です。
Gebは、Groovyの言語機能を生かした簡潔な記述と、
jQueryライクなDOMへアクセスするための式言語が特徴となっています。

Geb自体はその実装にテスティングフレームワークを含んでおらず、任意のテスティングフレームワークと
組み合わせて使えるようになっています。Gebのドキュメント^[[http://www.gebish.org/manual/current/](http://www.gebish.org/manual/current/)]では、組み合わせの例としてSpock,JUnit,
TestNGおよびCucumber-JVMが示されています。

本稿では、例示に使うテスティングフレームワークとしてSpockを使用します。
SpockとGebが同じGroovyで記述されていることによる親和性の高さや、
BDDスタイルでシナリオを記述することがエンドツーエンドのテストの
シナリオを記述する上で使い勝手がよいためです。[@lst:040_code2]

```{#lst:040_code2 caption="Spockによる記述"}
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
テスト内の画面遷移が正しいかを検証します。[@lst:040_code1] 

```{#lst:040_code1 caption="ページオブジェクト"}
class GebishOrgHomePage extends Page {

    static at = { title == "Geb - Very Groovy Browser Automation" }

    static content = {
        manualsMenu { module(ManualsMenuModule) }
    }
}
```

### ページオブジェクト上でのDOM要素の特定について

Selenium WebDriverによってテストを記述する上でのセオリーとして、テストが
記述するDOM上の要素に一意になるhtmlの`id`要素を振って、テストからDOMを
参照する際は`id`要素を使ってアクセスするというものがあります。

しかし近年のWebアプリケーション開発では、シングルページアプリケーション(SPA)の場合
`id`要素を一意にするにはアプリケーション全体で`id`要素を一意にする必要があるという
問題がありました。

さらにWebアプリケーションのUIがリッチになる中でアプリケーションが動的に
DOMを生成することがありふれるものとなると、html内にhtmlの
要素として`id`を記述すること自体がアプリケーションの開発スタイルと
そぐわないものになってきました。

このため、Gebによるエンドツーエンドのテストでページオブジェクトを
使用する場合は、
ページオブジェクトのプロパティ上で、この次に述べる`$`を使用したjQueryライクのまっチャーを使用してDOMの要素を特定し、
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
GroovyのmethodMissingという仕組みを使って
`geb.Browser`クラス ^[[https://github.com/geb/geb/blame/master/module/geb-core/src/main/groovy/geb/Browser.groovy](https://github.com/geb/geb/blame/master/module/geb-core/src/main/groovy/geb/Browser.groovy)]
を経由して呼び出される`geb.navigator.Navigator` ^[[http://www.gebish.org/manual/current/api/geb/navigator/Navigator.html](http://www.gebish.org/manual/current/api/geb/navigator/Navigator.html)]クラスのオブジェクトです。

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

Gebでは非同期処理の記述を行うには、要素の出現判定する処理のブロックを `waitFor{ 条件 }`で囲みます。タイムアウトは`GebConfig.groovy`の`waiting`ブロックのクロージャーで`timeout`プロパティーを設定します。

また、ページオブジェクトを使用している場合は、

` toggle(wait:true) { $("div.menu a.manuals") }`

のようにコンテントに`wait:true`を指定することで、ページオブジェクトを
操作する際に要素の出現を待機することが出来るようになります。[@PoohSunny2014]

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

上記の例では、`build.gradle`内で`geb.env`にドライバーの種別を指定しています。

Gebでは、
使用するWebDriverを指定する上で`GebConfig.groovy`内の`driver`という変数に

- WebDriverの実装クラス名を指す文字列
- WebDriverのインスタンスを返すクロージャー

のどちらか示すという仕様があり^[[http://www.gebish.org/manual/current/#driver-class-name](http://www.gebish.org/manual/current/#driver-class-name)]、それぞれのブロック内でその処理を行っています。

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

それに対して、各ブラウザーの開発元がDriverの実装を提供するという枠組みになっています。
`geb-example-gradle`ではChromeとFirefoxでの実装を指定する例が提供されて
います。

この際、ブラウザーによってはブラウザーとの間とのブリッジとなるネイティブランタイムを
配置する必要があります。その場合、ランタイムのパスはWebDriverの指定とは別のシステムプロパティーで指定します。

### Chrome

Chromeでは`chromedriver.exe`ないし`chromedriver`への絶対パスをシステムプロパティー
`webdriver.chrome.driver`で
指定します。

### Headless Chrome

Chrome59より実装されたヘッドレス機能を使用するには、`GebConfig.groovy`のdriverを指定するクロージャー内で
`org.openqa.selenium.chrome.ChromeOptions`に`headless`オプションを指定します。

```
	chromeHeadless {
		driver = {
			ChromeOptions o = new ChromeOptions()
			o.addArguments('headless')
			new ChromeDriver(o)
		}
	}
```	

### Firefox

Firefoxでは`geckodriver.exe`ないし`geckodriver`への絶対パスをシステムプロパティー`webdriver.gecko.driver`で指定します。

### Internet Exploer(IE)

Internet Exploer 11(IE11)では`IEDriverServer.exe`への絶対パスをシステムプロパティー
`webdriver.ie.driver`で指定します。また、`InternetExplorerDriver`ではInternetExploerの「保護モード」の設定を、セキュリティ設定の各ゾーンで同一に
する必要があるという仕様があるため、保護モードの設定を必要に応じて変更します。[@fig:040_c_image]

![IE11の保護モードの設定](src/img/ie.png){#fig:040_c_image}

### Edge

Edgeでは`MicrosoftWebDriver.exe`へのパスをシステムプロパティー`webdriver.edge.driver`に設定します。

また、開発者の端末はWindowsであり、継続的インテグレーション(CI)のサーバー上では
Linuxで実行されるように、複数の端末上でテストが実行される場合、スクリプト内で実行
されるOSの判定を行い、適切な設定を行います。

OSの判定は、`build.gradle`内ではGradleの`org.apache.tools.ant.taskdefs.condition.Os`で行います。
`GebConfig.groovy`内で判定を行う場合はサードパーティーのライブラリーであるCommons Langの`org.apache.commons.lang.SystemUtils`を用いて行います。

テスト実行のプロファイル事にDriverの実装を切り替えることにより、単一の
アプリケーションに対してクロスブラウザーでのエンドツーエンドのテストを
行うことが可能です。
ですが、InternetExploerやEdgeのDriver実装は、非同期処理を伴わない
画面遷移であっても、`GebConfig.groovy`の`waiting`ブロックによる
タイムアウトの設定を長めにとらないとDOMの要素を適切に取得できないなどの
問題があり、このようなテスト実行の上で考慮すべき問題はブラウザーごとに
存在します。

UIの単体テストでなく、アプリケーションのシナリオを通じてユースケースを
実現しているかの受け入れてとしてエンドツーエンドのテストを行うのであれば、
アプリケーションが動作対象とするブラウザーの中からエンドツーエンドの
テストの対象とするブラウザーをピックアップすることが望ましいです。
そのテスト運用が安定してから、さらなる品質向上を目指してクロスブラウザー
でのエンドツーエンドのテストに取り組むのが良いでしょう。

## マルチステージ

先述した通り、Gebでは、実行時にシステムプロパティー`geb.env`を設定することにより、
`GebConfig.groovy`の`environments`ブロックで設定値の切り替えを行うことが
できます。これを使用した`GebConfig.groovy`の記述のサンプルは以下の通りと
なります。

## レポーティング

SpockではRenato Athaydes氏が開発しているspock-reports^[[https://github.com/renatoathaydes/spock-reports](https://github.com/renatoathaydes/spock-reports)]という拡張を
使用することにより、BDDに即した形でのレポート表示を行うことが可能です。[@fig:040_b_image]

![spock-reportsによるレポート表示](src/img/spock-report.png){#fig:040_b_image}


SpockでGebのテストを記述する際、Featur Method内の`given`-`when`-`then`内に
文字列でシナリオを記述することにより、レポートで見た際にテストが
行っていることをわかりやすく記述させることができます。

```
    then: "currentのリンクがcurrentではじまっている"
    manualsMenu.links[0].text().startsWith("current")
```

Gebでspock-reportsを使用するには、build.gradleで`com.athaydes:spock-repots`を依存性に追加します。

この際、Gebが依存するSpockのバージョンが`1.0-groovy-2.4`であり、
spock-reportsが依存するのは`1.1-groovy-2.4`であるため、
上記を共存させるための`build.gradle`は次の通りとなります。

```
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

## スクリーンショット取得時の注意点

Gebでは`geb.spock.GebReportingSpec`を継承することで、テストの実行時に
自動でスクリーンショットを取得することができます。

この際、スクリーンショットのファイル名はFeature Methodの名称に従って作成
されますが、Spockの場合はJavaで扱うことのできる文字列であればメソッドの
名称に制約がないので、実行するOSのファイルシステムで扱うことのできない
文字はテストを実行する側でエスケープする必要があります。

文字列をエスケープするには、`GebConfig.groovy`に以下の通りの
記述を追加します。

```
reporter = new CompositeReporter(new PageSourceReporter(),
 new ScreenshotReporter() {
    @Override
    protected escapeFileName(String name) {
        name.replaceAll(/^[\\\/:\*?"<>\|\s]+$/, "_")
    }
})
```
## Gebのリソース

Gebは公式の英語によるドキュメント^[[http://www.gebish.org/manual/current/](http://www.gebish.org/manual/current/))]が充実しており、Gebを活用するにあたっては
まずこちらを参照するとよいでしょう。

またGebのソースコード^[[https://github.com/geb/geb](https://github.com/geb/geb)]は
Groovyのソースコードリーディングの題材として優れているので、
GebのAPI呼び出しからメタプログラミングやAST変換がどのように動いているのか
興味をお持ちでしたらソースコードを眺めてみるのもよいでしょう。

日本語のリソースとしては、WEB+DB PRESS VOL.85の「GebによるスマートなE2Eテスト」[@Sato2015]が
あげられます。

また2016年12月に開かれた「Geb Advent Calendar 2016」^[[https://qiita.com/advent-calendar/2016/geb](https://qiita.com/advent-calendar/2016/geb)] にも日本語でのGebに関するエントリーが集積されています。

Gebのメイン開発者であるMarcin Erdmann氏はカンファレンスに登壇した際に
GebのContributorを全員紹介するなど^[筆者はGebのContributorです。] ^[[https://youtu.be/yKFHmLYCfn0?t=2m9s](https://youtu.be/yKFHmLYCfn0?t=2m9s)]] 気さくな性格であり、Gebのコミュニティーはプルリクエストなどの要望にも丁寧に対応してくれます。

GebによるエンドツーエンドのテストはSpockと組み合わせることで、
BDDスタイルのテスト記述やレポート出力など、上位のテストレベルと
してのエンドツーエンドテストに求められる機能を備えることができます。

また、GebとSpockの組み合わせにより、GroovyのJavaライクな軽量の
スクリプト記述を生かすことができます。本稿がみなさんの
Gebによるテスト記述のきっかけになれば幸いです。


