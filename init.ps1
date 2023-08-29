function createIfNotExist {
    param (
        [string]$path
    )
    if (!(Test-Path $path)) { 
        mkdir $path
    }
}

function ipUpdate {
    param (
        [string]$ip,
        [int]$increment
    )

    $ip = $ip.Trim()
    $octets = $ip.Split(".")
    $lastOctet = [int]$octets[3] + $increment

    if ($lastOctet -gt 254) {
        $lastOctet = 254
    }
    elseif ($lastOctet -lt 0) {
        $lastOctet = 0
    }

    $octets[3] = [string]$lastOctet
    $tmpIP = $octets -join "."
    $tmpIP
}

$vmNumber = 3;
if ($IsWindows) {
    $installPathOS = "C:/"
    $syshostsPath = "C:/Windows/System32/drivers/etc/hosts"
}
else {
    $installPathOS = "~/"
    $syshostsPath = "/etc/hosts"
}

$Client = Read-Host -Prompt 'Insérer le nom du client'
$paths = @('travail/', 'commun/', 'config/', $Client)

$installPath = $installPathOS
foreach ($path in $paths) {
    $installPath = $installPath + $path
    createIfNotExist -path $installPath
}

$commonPath = $installPathOS + 'travail/commun/'
$configPath = $commonPath + 'config/'
$clientPath = $configPath + $Client + '/'
$clientConfigPath = $clientPath + "config"
$vagrantPath = $installPath + "/VagrantFile"
$templatePath = $commonPath + "template/"
$ipPath = $commonPath + "next.txt"

$IPv4 = Get-Content $ipPath
$fileContent = Get-Content -Path ($templatePath + "VagrantFile") -Raw
cp -r ($templatePath + "playbook") $clientConfigPath

Add-Content -Path ($configPath + "/HOST") -Value "[$Client]"
for ($i = 0; $i -lt $vmNumber; $i++) {
    $stringToReplace = "{{IP" + ($i + 1) + "}}"

    $newIP = (ipUpdate -ip $IPv4 -increment $i)
    Add-Content -Path ($configPath + "/HOST") -Value $newIP
    $fileContent = $fileContent -replace $stringToReplace, $newIp

    switch ($i) {
        1 { $httpdIP = $newIP }
        2 { $apiIP = $newIP }
    }
}

$fileContent | Set-Content -Path $vagrantPath

Set-Content -Path $ipPath -Value (ipUpdate -ip $IPv4 -increment ($vmNumber))

$Cursor = [System.Console]::CursorTop
Do {
    [System.Console]::CursorTop = $Cursor
    $addHost = Read-Host -Prompt 'Voulez-vous ajouter $Client.com et $api.$Client.com au fichier hosts (y/n)'
}
Until ($addHost -eq 'y' -or $addHost -eq 'n')

if ($addHost -eq 'y') {
    $hostContent = "$httpdIP `t$Client.com`n$apiIP `tapi.$Client.com"
    if ($IsWindows) {
Start-Process powershell -Verb runAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command { Add-Content -Path `"$syshostsPath`" -Value `"$hostContent`" }"
    }
    else {            
        $hostContent | sudo tee -a $syshostsPath
    }
}