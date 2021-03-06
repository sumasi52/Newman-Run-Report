$scriptPath = $MyInvocation.MyCommand.Path
cd (Split-Path -Parent $scriptPath)


#変数リセット
$totalTestsFailed = 0
$totalTestScriptsFailed = 0

Start-Transcript -path ".\newman\log\newman-run-report.log" -Append #テキストログ出力
$startDate = Get-date
$nowDate = Get-date
Write-Host "`r`n------------${nowDate}: テスト開始------------" -ForegroundColor Green


###################################################################################################

newman run example.postman_collection.json -r html,json #PostmanのCollectionファイルを指定

###################################################################################################

# .\newman\最新json 読み込み
$files = @(Get-ChildItem -Path .\newman -Filter *.json)
cd .\newman
$jsontext = Get-Content $files[$files.length - 1] -Encoding UTF8 -Raw
cd .\..
$report = $jsontext | ConvertFrom-Json


#結果出力
Write-Output $report.run.stats
$totalRunDuration = ($report.run.timings.completed - $report.run.timings.started)/1000
$responseAverage = $report.run.timings.responseAverage
$responseAverage = $responseAverage.ToString("0.00")
$totalTestsFailed += $report.run.stats.tests.failed
$totalTestScriptsFailed += $report.run.stats.assertions.failed + $report.run.stats.testScripts.failed
Write-Host "Total run duration : ${totalRunDuration}s"
Write-Host "responseAverage    : ${responseAverage}ms`r`n"


#エラー出力
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


$nowDate = Get-date
Write-Host "------------${nowDate}: 全テスト終了------------`r`n" -ForegroundColor Green

Write-Host "`r`n============================================================`r`n"
Stop-transcript


# Slack投稿
if($totalTestsFailed + $totalTestScriptsFailed -eq 0){
    $output = "---*${startDate}開始テストレポート*---`r`n全テスト終了`r`n :large_blue_circle:エラーなし"

}else{
    $scriptParentPath = Split-Path -Parent $scriptPath
    $files = @(Get-ChildItem -Path .\newman -Filter *.html)
    $errorHtml = $files[$files.length - 1].Name
    $output = 
    "---*${startDate}開始テストレポート*---`r`n全テスト終了`r`n
リクエスト:${totalTestsFailed}回失敗, テストスクリプト:${totalTestScriptsFailed}回失敗`r`n
>>>${arraySlackMessages}`r`n
_file:///${scriptParentPath}/newman/${errorHtml}_"
remove-variable arraySlackMessages
}

$message = $output -join "`n"
$payload = @{ 
    fallback = "fallback Test"
    text = $message;
}

###################################################################################################

$webhook = "https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXX" #Slack Webhookを入力

###################################################################################################

$json = ConvertTo-Json $payload
$body = [System.Text.Encoding]::UTF8.GetBytes($json)
Invoke-RestMethod -Uri $webhook -Method Post -Body $body
