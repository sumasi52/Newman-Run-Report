$scriptPath = $MyInvocation.MyCommand.Path
cd (Split-Path -Parent $scriptPath)

#処理を途中で終了した用
$configurationFlag = 0
$totalTestsFailed = 0
$totalTestScriptsFailed = 0

#テスト設定
while($configurationFlag -ne 1){
    $frequently =[int](Read-Host テストの間隔を入力してください（秒単位）)
    $testTimes =[int](Read-Host テストを何回行いますか（0を入力した場合無限）)
    Write-output "`r`n"
    $allTestTimes = $testTimes * 20
    $allTestTimes += $frequently * $testTimes

    $h = [int]($allTestTimes/3600)
    $allTestTimes %= 3600

    $m = [int]($allTestTimes/60)
    $allTestTimes %= 60

    $s = $allTestTimes
    $msgBoxInput = [System.Windows.Forms.MessageBox]::Show('全テストにおよそ'+"${h}時間${m}分${s}秒"+'かかります。 実行しますか?','テストの実行確認','YesNo','Question')
 
    switch ($msgBoxInput) {
     
        'Yes' {
 
       $configurationFlag = 1

       }
 
       'No' {

       $configurationFlag = 0

       }
 
    }
}

$startDate = Get-date


#テストスクリプト
Start-Transcript -path ".\newman\log\newman-run-report.log" -Append #テキストログ出力
for($i=0; $i -lt $testTimes -or $testTimes -eq 0; $i++){
if($i -ne 0){
    powershell sleep $frequently
}
$nowDate = Get-date
Write-output "`r`n----------${nowDate}: テスト開始----------"

###################################################################################################

newman run example.postman_collection.json -r html,json #PostmanのCollectionファイルを指定

###################################################################################################

# .\newman\最新json 読み込み
$files = @(Get-ChildItem -Path .\newman -Filter *.json)
cd .\newman
$jsontext = Get-Content $files[$files.length - 1] -Encoding UTF8 -Raw
cd .\..
$report = $jsontext | ConvertFrom-Json

echo $report.run.stats
$totalRunDuration = ($report.run.timings.completed - $report.run.timings.started)/1000
$responseAverage = $report.run.timings.responseAverage
$responseAverage = $responseAverage.ToString("0.00")
$totalTestsFailed += $report.run.stats.tests.failed
$totalTestScriptsFailed += $report.run.stats.assertions.failed + $report.run.stats.testScripts.failed
echo "Total run duration : ${totalRunDuration}s"
echo "responseAverage    : ${responseAverage}ms"

foreach($failure in $report.run.failures){
    $failureSource = $failure.source.name
    if($failure.error.test -eq $null){
        $failureName = $failure.error.name
    }else{
        $failureName = $failure.error.test
    }
    $failureMessage = $failure.error.message
    Write-Host "Fail ${failureSource}: ${failureName}`r`n     Message ${failureMessage}`r`n" -ForegroundColor Red
    $arraySlackMessages += ":red_circle: ${failureSource}: ${failureName}`r`n         Message ${failureMessage}`r`n`r`n"
}

$csvReport = [pscustomobject]@{
    Time=Get-date;
    TotalRunDurarion=$totalRunDuration;
    ResponseAverage=$responseAverage;
    PassTests=$report.run.stats.tests.total;
    FailTests=$report.run.stats.tests.failed;
    PassTestScripts=$report.run.stats.assertions.total + $report.run.stats.testScripts.total;
    FailTestScripts=$report.run.stats.assertions.failed + $report.run.stats.testScripts.failed
}
$csvReport | Export-Csv -path .\newman\log\newman-run-report.csv -Append -NoTypeInformation #csv出力
Write-Host "------------------------------------------------------------`r`n"
}

remove-variable configurationFlag #変数削除
Write-output "${nowDate}: 全テスト終了: ${frequently}秒間隔, ${testTimes}回"
Write-Host "`r`n============================================================`r`n"
Stop-transcript

# Slack投稿
if($totalTestsFailed + $totalTestScriptsFailed -eq 0){

$output = "---${startDate}開始テストレポート---`r`n全テスト終了: エラーなし"
}else{
$scriptParentPath = Split-Path -Parent $scriptPath
$files = @(Get-ChildItem -Path .\newman -Filter *.html)
$errorHtml = $files[$files.length - 1].Name
$output = 
"---*${startDate}開始テストレポート*---`r`n全テスト終了`r`n
リクエスト:${totalTestsFailed}回失敗, テストスクリプト:${totalTestScriptsFailed}回失敗`r`n
>>>${arraySlackMessages}`r`n
<file:///${scriptParentPath}/newman/${errorHtml}>"

}
$message = $output -join "`n"
$payload = @{ 
    text = $message;
}

###################################################################################################

$webhook = "https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXX" #Slack Webhookを入力

###################################################################################################

$json = ConvertTo-Json $payload
$body = [System.Text.Encoding]::UTF8.GetBytes($json)
Invoke-RestMethod -Uri $webhook -Method Post -Body $body

remove-variable arraySlackMessages
pause