if ($IsWindows) {
    $installPathOS = "C:/"
}
else {
    $installPathOS = "~/"
}

#variable de chemin  utiliser dans le script
$commonPath = $installPathOS + 'travail/commun/'
$configPath = $commonPath + 'config/'
$vagrantHosts = $configPath + ".hosts/"
$hostFile = "/HOST"

#variable de chemin des fichiers
$hostPath = $configPath + $hostFile

Write-Output "`nClients dans hosts`n"
$validName = Get-ChildItem -Path $vagrantHosts -Name
$exitOption = "-q"

do {
    Write-Output "Noms de clients valides:`n$validName"
    $client = Read-Host -Prompt "Insérer le nom du client que vous voulez retirer du fichier HOST de Ansible ('$exitOption' pour quitter)"

    if ($client -eq $exitOption) {
        Write-Output "Opération annulé"
        exit
    }
    
} until ($validName -contains $client)

$vagrantHostsFile = $vagrantHosts + $client

$contentToRemove = Get-Content -Path $vagrantHostsFile
$contentToClean = Get-Content -Path $hostPath

$newContent = @()
foreach ($line in $contentToClean) {
    if ($contentToRemove -notcontains $line) {
        $newContent += $line
    }
}

$newContent | Set-Content -Path $hostPath
Remove-Item $vagrantHostsFile
Write-Output "Fichier HOST Nettoyer"
Read-Host -Prompt 'Appuyer sur Entrée pour quitter'
