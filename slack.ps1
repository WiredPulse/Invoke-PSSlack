function Slack($chan){
# https://bluescreenofjeff.com/2017-04-11-slack-bots-for-trolls-and-work/
# https://api.slack.com/custom-integrations/legacy-tokens

$uri = 'https://slack.com/api/chat.postMessage'
$token = Get-Content .\logger_api.txt
$channel = $chan
$message = "howdy"
$botname = "logger"    
$emoji = ":incoming_envelope"

$body = @{
    token    = $token
    channel  = $Channel
    text     = $Message
    username = $BotName
    icon_emoji = $emoji
    parse    = 'full'
}

Invoke-RestMethod -Uri $uri -Body $body
} # Slack

function Slack-Logger($chan){
$date = (get-date).AddMinutes(-10)

$uri = 'https://slack.com/api/chat.postMessage'
$token = Get-Content .\logger_api.txt
$channel = $chan
$botname = "logger"
$emoji = ":incoming_envelope"

$logs = Get-WinEvent -FilterHashtable @{logname='security';id='4688';starttime=$date} |select timecreated, @{Label="Process";Expression={$_.properties.value[5]}}, @{Label="Commandline";Expression={$_.properties.value[8]}}, @{Label="Account";Expression={$_.properties.value[1]}}, @{Label="Creator";Expression={$_.properties.value[13]}}

$logs | Add-Member -MemberType ScriptProperty -Name 'Message' -Value {$null}
$obj = @()

$obj = foreach($item in $logs){
    [pscustomobject]@{
        TimeCreated = $item.TimeCreated
        Process = $item.Process
        Commandline = $item.commandline
        Account = $item.account
        Creator = $item.creator
        }
}

foreach($message in $obj){
    $mes = "Time Created: $($message.timecreated)`nProcess: $($message.process)`nCommandline: $($message.commandline)`nAccount: $($message.account)`nCreator: $($message.'creator')`n----------------"
    $body = @{
        token    = $token
        channel  = $Channel
        text     = $mes
        username = $BotName
        icon_emoji = $emoji
        parse    = 'full'
    }
Invoke-RestMethod -Uri $uri -Body $body
Remove-Variable obj -ErrorAction SilentlyContinue
}
start-sleep -Seconds 600
} # Slack-Logger
