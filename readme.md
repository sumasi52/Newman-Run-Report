# Newman Run Report
# 仕様
## 動作
実行すると`newman`フォルダが作成され、結果が保存されていきます
`newman`ディレクトリにはhtml、json形式の結果
![PostmanCreateCollectons1](https://raw.githubusercontent.com/sumasi52/Photo/master/specification1.PNG)

`newman\log`ディレクトリにはcsv形式の結果とlog形式のスクリプトログ
![PostmanCreateCollectons1](https://raw.githubusercontent.com/sumasi52/Photo/master/specification2.PNG)

<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/specification3.PNG" width=80%>

さらに、任意のSlackチャンネルに結果の通知が送られます
![PostmanCreateCollectons1](https://raw.githubusercontent.com/sumasi52/Photo/master/specification5.PNG)
![PostmanCreateCollectons1](https://raw.githubusercontent.com/sumasi52/Photo/master/specification4.PNG)

また、WindowsタスクスケジューラにNewman Run Reportを登録するとテストを好みのタイミングかつ、バックグラウンドで行うことができます
![PostmanCreateCollectons1](https://raw.githubusercontent.com/sumasi52/Photo/master/specification6.PNG)

## 必要条件
* Windows Powershell 3.0以上
* Node.js via package manager v6以上
* Newman v4

# 使用方法
## 流れ
1. Postmanをインストール
2. Postmanにて`Collections`を作成し、json形式で出力
3. Newmanをインストール
1. Slack Incoming Webhook URL を取得
4. `Newman-Run-Report`に入っている`Report.ps1`を編集し、同じディレクトリに#2で作成したjsonファイルを配置
1. （オプション）WindowsタスクスケジューラにNewman Run Reportを登録する

## 1.Postmanをインストール
まだインストールしていない場合は[こちら](https://www.getpostman.com/)からインストールしてください

## 2.Postman

#### Collectionsを作成

1. 画面左側の`+`を押す
![PostmanCreateCollectons1](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-1.png)

1. 名前を適当につけたら右下の`Create`で作成
![PostmanCreateCollectons2](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-2.png)
他の項目は後から変更できます

#### Requestsを作成
`Add requests`や`Save As...`などからCollectionsにRequestsを追加
![PostmanCreateCollectons3](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-27.png)
![PostmanCreateCollectons3](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-3.png)
お好みでRequests内容を編集してください

#### トークン設定

1. 画面右上の`歯車`を押す
<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/postman-4.png" width=50%>

1. `Add`を押し、適当な名前をつけて再び`Add`
<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/postman-5.png" width=80%>

1. 画面右上の`No Environment`を押し、作成した環境を選択
![PostmanCreateCollectons4](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-7.png)

1. Collectionsの`...`を押し、`Edit`に進む
![PostmanCreateCollectons4](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-10.png)

1. `Authorization`タブのTYPEを任意のものに変更し、Tokenを`{{token}}`とする
![PostmanCreateCollectons4](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-11.png)

1. Bodyにtokenが返るRequestsの場合
![PostmanCreateCollectons4](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-29.png)
![PostmanCreateCollectons4](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-31.png)
`Tests`に以下の記述をするとPostman内の環境変数`token`にBody内のtokenが代入されます
```
var data = JSON.parse(responseBody);
postman.setEnvironmentVariable("token", data.token);
```
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-30.png)

#### Tests設定
もし`アカウント登録`→`アカウント削除(更新)`にランダムなアカウントIDを用いていた場合、一連の流れでテストを行うことができません。そこで、先ほどのトークン設定で用いた環境変数に代入を利用します。

アカウント登録のリクエストを送ると以下のようなBodyが返ってくるので
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-17.png)

Testsタブに以下の記述を入力するとBodyに返ってきた連想配列内の`id`がPostmanの環境変数に`id`として登録されます
```
var data = JSON.parse(responseBody);
postman.setEnvironmentVariable("id", data.id);
```
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-18.png)

環境画面を見るとVARIABLEに`id`が追加されていることが確認できます
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-19.png)

次にアカウント更新のURLを次のように変更します
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-20.png)
Postmanでは`{{環境変数名}}`と入力すれば基本的にどこでも環境変数に置き換えられます。そのため`アカウント作成`のTestsで環境変数`id`に代入された値がURLに代入され、ランダムなアカウントIDに対応することができます。


これまでは変数代入のためにTestsを利用しましたが、このTestsにはその名のとおりテストしたい内容を記述してテストすることができます。
例えば
```
pm.test("Response time is less than 200ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(200);
});
```
と記述すればレスポンス200ms以上の場合、Failedとなります
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-24.png)
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-25.png)

このTestsはCollectionsごとにも管理できます
<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/postman-32.png" width=80%>

テストスクリプトはjavascriptで記述でき、画面右の`SNIPPETS`から追加できる例文や[公式ドキュメント](https://learning.getpostman.com/docs/postman/scripts/test_scripts/)を参考にカスタマイズするとさらなる効率化が図れます

#### Runnerで確認

作成したCollectionsを一括でテストしてみましょう
1. 作成したCollectionsの`三角マーク`を押す
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-12.png)

1. `Run`を押す
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-13.png)
Runnerが起動します

1. 左下の`Run Collection`を押す
<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/postman-14.png" width=50%>

1. 自動でコレクション内のテストが始まり、結果が出ます
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-15.png)
<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/postman-16.png" width=80%>

 作成した場合、Testsの結果も出ます
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-26.png)

#### json出力
ここまでがうまくいっているのであればコレクションをjson形式で出力します

1. Collectionsの`...`から`Export`を押す
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-33.png)

1. v2.1が選択されていることを確認し、`Export`を押す
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-34.png)

## 3.Newmanをインストール
1. NewmanのインストールにはNode.js via package manager v6 以上が必要です
無い場合[ここ](https://nodejs.org/ja/)から最新版をインストールしてください

1. コマンドラインで`npm install -g newman`と入力

1. (オプション)コマンドラインで`newman -v`と入力し、バージョンが返ってくるか確認

## 4.Slack Incoming Webhook URLを取得
1. Slackの通知を受けたいワークスペースにサインインした状態で[Slack Incoming Webhook](https://slack.com/services/new/incoming-webhook)にアクセス

1. 通知したいチャンネルを選択し、インテグレーションの追加を押す
![SlackWebhook](https://raw.githubusercontent.com/sumasi52/Photo/master/slackwebhook2.PNG)

1. Webhook URLに記述されているURLをコピー
![SlackWebhook](https://raw.githubusercontent.com/sumasi52/Photo/master/slackwebhook.PNG)

## 5.Newman Run Report
#### 準備1 - スクリプト編集
1. `Newman-Run-Report\タスクスケジューラ使用版 or 未使用版`内のReport.ps1と同じディレクトリに「Postman」で作成した`collection.json`を配置
![NewmanRunReport](https://raw.githubusercontent.com/sumasi52/Photo/master/newman-1.PNG)

2. `Report.ps1`をメモ帳などで開き、`#`で囲まれた部分を編集する
`newman run example.postman_collection.json -r html,json`の部分のjson名を「Postman」で作成した`collection.json`の名前に編集
![NewmanRunReport](https://raw.githubusercontent.com/sumasi52/Photo/master/newman-2.PNG)

 `$webhook = "https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXX`の部分を「Slack Incoming Webhook」で取得したURLに編集
![NewmanRunReport](https://raw.githubusercontent.com/sumasi52/Photo/master/newman-3.PNG)　　

#### （オプション）準備2 - Pwershell設定

Newman-Run-Reportを使用するには`Windows Powershell 3.0以上`が必要ですが、
OSごとにデフォルトでインストールされているバージョンが違います。
バージョンが気になる方はPowershellに`Get-Host`と入力するとバージョンが確認できます。

|Windows OSバージョン|デフォルト|導入可能|
|:---|:---:|:---|
|Windows Server 2016|5.1|(6.0)|
|Windows 10 RS1|5.1|(6.0)|
|Windows 10|5.0|5.1/(6.0)|
|Windows Server 2012 R2|4.0|5.0/5.1/(6.0)|
|Windows 8.1|4.0|5.0/5.1/(6.0)|
|Windows 2012|3.0|4.0/5.0/5.1/(6.0)|
|Windows 8|3.0|4.0/5.0/5.1/(6.0)|
|Windows Server 2008 R2|2.0|3.0/4.0/5.0/5.1/(6.0)|
|Windows 7 SP1|2.0|3.0/4.0/5.0/5.1/(6.0)|
|Windows Server 2008 SP2|1.0|2.0/3.0/4.0/5.0/5.1/(6.0)|

デフォルトのバージョンが2.0以下の場合はPowershellのバージョンアップを行ってください
`Windows Manage Framework (WMF)`をバージョンアップするとWMFに含まれるPowershellもバージョンアップされます。今回は比較的新しく、安定しているPowershell5.1にアップデートします。

[WMF5.1のインストールと構成](https://docs.microsoft.com/ja-jp/powershell/wmf/5.1/install-configure)からご使用のOSに合うパッケージをダウンロード
しかしこのままではうまく実行できません。デフォルトでは`Posershellスクリプト(.ps1)`の実行禁止という実行ポリシー[^1]になっているからです。なので、実行ポリシーを変更します。
[^1]:https://docs.microsoft.com/ja-jp/previous-versions/windows/powershell-scripting/hh847748(v=wps.640)

##### Powershellの実行ポリシーの変更

管理者として実行しているPowershell上で`Set-ExecutionPolicy AllSigned`と入力
![Powershell](https://raw.githubusercontent.com/sumasi52/Photo/master/power1.PNG)
すると画像のように質問されるので`Y`を入力
***
再び、Pwershellバージョンアップ作業にもどります

1. ダウンロードしたzipファイルを解凍し、`Install-WMF5.1.ps1`を管理者としてPwershellで実行
1. 実行するか聞かれるので`R`を入力
![Powershell](https://raw.githubusercontent.com/sumasi52/Photo/master/power2.PNG)

あとは表示に従って進めていくとバージョンアップができます

#### スクリプト実行
`Report.ps1`をPowershellで実行すると`newman`フォルダが作成され、その中にログがたまっていきます。また、Slackの指定したチャンネルに結果が通知されます。

## 6.（オプション）WindowsタスクスケジューラにNewman Run Reportを登録する
テストを一定期間ごとに行いたい場合はWindowsタスクスケジューラにNewman Run Reportを登録します
1. タスクスケジューラを起動
1. `操作`→`タスクの作成`をクリック
<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/task1.png" width=50%>

1. 全般の名前は任意のものを、`ユーザーがログオンしているかどうかにかかわらず実行する`と`最上位の特権で実行する`にチェック
<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/task2.PNG" width=75%>

1. トリガーは任意のものを追加
<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/task3.PNG" width=75%>

1. 操作の`新規`から新しい操作を作成
1. 「プログラム/スクリプト」を`C:\Newman-Run-Report\タスクスケジューラ使用版\task-scheduler.js`のように`task-scheduler.js`のパスを指定
1. 「引数の追加」を`"C:\Newman-Run-Report\タスクスケジューラ使用版\Report.ps1"`のように`Report.ps1`のパスを指定
<img src="https://raw.githubusercontent.com/sumasi52/Photo/master/task4.PNG" width=70%>

1. そのほかの項目はお好みで変更し`OK`を押すとトリガー条件を満たしたときにNewman Run Reportが実行されます

<br>

# License
This software is released under the MIT License.  
# Author
 * **sumasi** [sumasi Room](https://github.com/sumasi52)
