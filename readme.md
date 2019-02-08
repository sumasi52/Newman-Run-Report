# Newman-Run-Report
Postmanの複数リクエストを自動テストし、結果をレポートします。
また、Slackに通知します。


## Dependency
Windows Powershell 3.0以上  
Node.js via package manager v6以上  
Newman v4

## Setup
1. Newmanをインストール ```npm install -g newman```

2. Postmanにてcollectionをエクスポート（json形式）

3. collection.jsonをReport.ps1と同じディレクトリに配置

4. Report.ps1内の`#`で囲まれた部分を任意の名前に変更



## Usage
Report.ps1を起動すると自動的にテストが行われ、レポートが `.\newman`内に記録される

タスクスケジューラ使用版を利用の際はWindowsに搭載されているタスクスケジューラよりスケジュール設定ができる

### タスクスケジューラプロパティ  
#### 全般  
 最上位の特権で実行

#### 操作  
 プログラム/スクリプト  task-scheduler.jsのパスを入力 Ex`C:\Newman-Run-Report\タスクスケジューラ使用版\task-scheduler.js`  
 引数の追加  Report.ps1のパスを入力 Ex`"C:\Newman-Run-Report\タスクスケジューラ使用版\Report.ps1"`  
その他のプロパティは任意  

## Licence
This software is released under the MIT License, see LICENSE.

## Authors
* **sumasi** [sumasi Room](https://github.com/sumasi52)


## References
https://www.npmjs.com/package/newman#newman-the-cli-companion-for-postman  
https://api.slack.com/incoming-webhooks