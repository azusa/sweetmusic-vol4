\lhead[]{}
\rhead[]{}
\chead[DevOps再考]{DevOps再考}

# DevOps再考

## DevOpsとは

 DevOpsとは、開発を示す「Dev」と運用を示す「Ops」の合成語です。
 このためDevOpsを説明する時には「開発担当者（Dev）と運用担当者（Ops）が
 連携して協力し合う開発手法のこと」という説明をされたりします。

DevOpsという言葉が生まれたきっかけは、2008年にカナダのトロントで開かれた「Agile2008」^[[https://www.agilealliance.org/agile2008/
](https://www.agilealliance.org/agile2008/
)]
というカンファレンスです。ベルギーのITインフラを専門とするコンサルタントの
Patrick Debois氏による「Agile Infrastructure and Operations」^[[http://www.jedi.be/presentations/agile-infrastructure-agile-2008.pdf](http://www.jedi.be/presentations/agile-infrastructure-agile-2008.pdf)]という
セッションの中で、データセンターの移行というインフラ構築のプロジェクトに
アジャイル開発のプラクティスをどう適用するかという問題意識とその実践をまとめた発表です。

これを受けて2009年、米国サンノゼで開催されたVelocity 2009^[[https://conferences.oreilly.com/velocity/velocity2009
](https://conferences.oreilly.com/velocity/velocity2009
)]に
FlickrのエンジニアであるJohn Allspaw氏, Paul Hammond氏が「10+ Deploys per Day: Dev and Ops Cooperation at Flickr」という発表を行います。
このこのプレゼンテーションをベルギーからストリーミングで視聴していたPatrick Debois氏が、
「Devopsdays」というイベントを開く事を思い立ち、それが本格的なDevOpsムーブメントの始まりと
なったとされています。[@Edwards2012] ^[[http://itrevolution.com/the-history-of-devops/](http://itrevolution.com/the-history-of-devops/)]この流れは@marubinotto氏^[[https://twitter.com/marubinotto](https://twitter.com/marubinotto)]によって「DevOpsの起源とOpsを巡る対立」
^[[https://ubiteku.oinker.me/2015/07/01/devops%E3%81%AE%E8%B5%B7%E6%BA%90%E3%81%A8ops%E3%82%92%E5%B7%A1%E3%82%8B%E5%AF%BE%E7%AB%8B/](https://ubiteku.oinker.me/2015/07/01/devops%E3%81%AE%E8%B5%B7%E6%BA%90%E3%81%A8ops%E3%82%92%E5%B7%A1%E3%82%8B%E5%AF%BE%E7%AB%8B/)] としてまとめられています。

もともとソフトウェア開発は、「キーボードとディスプレイがあれば仕事が出来る」などと評されるように、
その対象となるドメインは、ソフトウェアとそれを構成するプログラミングの世界にある程度閉じて
います。それに対してインフラ構築やその運用は、サーバーやネットワーク機器、回線設備など、ハードウェアと
関わり合いを持つため、ソフトウェア開発の職能とはその性格を異にしています。

パブリッククラウドが普及する前、大規模なソフトウェア開発のプロジェクトというのは、サーバーやネットワーク機器を
収容するためのデータセンター内の配置や、場合によっては建築までを領域として含んでいました。

また筆者が若手エンジニアだったころのソフトウェア運用の現場というのは、定められた運用スケジュールに従って
ジョブスケジューラーを起動し、バッチプログラムが出力した帳票の出力結果を確認したり、業務部署に帳票を
配布するための専任のオペレーターが勤務しているのが常でした。







