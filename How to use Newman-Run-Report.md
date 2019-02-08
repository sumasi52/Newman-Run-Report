# Newman Run Reportの使い方

## 流れ
1. Postmanをインストール[1](#postmanをインストール)
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
![PostmanCreateCollectons4](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-4.png)

1. `Add`を押し、適当な名前をつけて再び`Add`
![PostmanCreateCollectons4](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-5.png)

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
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-32.png)

テストスクリプトはjavascriptで記述でき、画面右の`SNIPPETS`から追加できる例文や[公式ドキュメント](https://learning.getpostman.com/docs/postman/scripts/test_scripts/)を参考にカスタマイズするとさらなる効率化が図れます

#### Runnerで確認

作成したCollectionsを一括でテストしてみましょう
1. 作成したCollectionsの`三角マーク`を押す
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-12.png)

1. `Run`を押す  
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-13.png)  
Runnerが起動します

1. 左下の`Run Collection`を押す
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-14.png)  

1. 自動でコレクション内のテストが始まり、結果が出ます
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-15.png)  
![PostmanCreateCollectons](https://raw.githubusercontent.com/sumasi52/Photo/master/postman-16.png)

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
#### 準備
1. `Newman-Run-Report\タスクスケジューラ使用版 or 未使用版`内のReport.ps1と同じディレクトリに「Postman」で作成した`collection.json`を配置
![NewmanRunReport](https://raw.githubusercontent.com/sumasi52/Photo/master/newman-1.PNG)

2. `Report.ps1`をメモ帳などで開き、`#`で囲まれた部分を編集する  
`newman run example.postman_collection.json -r html,json`の部分のjson名を「Postman」で作成した`collection.json`の名前に編集
![NewmanRunReport](https://raw.githubusercontent.com/sumasi52/Photo/master/newman-2.PNG)

 `$webhook = "https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXX`の部分を「Slack Incoming Webhook」で取得したURLに編集
![NewmanRunReport](https://raw.githubusercontent.com/sumasi52/Photo/master/newman-3.PNG)

## Dependency
* Windows Powershell 3.0以上  
* Node.js via package manager v6以上  
* Newman v4

## Setup
1. Newmanをインストール ```npm install -g newman```

1. Postmanにてcollectionをエクスポート（json形式）

1. collection.jsonをReport.ps1と同じディレクトリに配置

1. Report.ps1内の`#`で囲まれた部分を任意の名前に変更
