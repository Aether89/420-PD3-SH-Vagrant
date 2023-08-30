if ($IsWindows) {
    $installPathOS = "C:/"
}
else {
    $installPathOS = "~/"
}

#variable de chemin  utiliser dans le script
$commonPath = $installPathOS + 'travail/commun/'
$configPath = $commonPath + 'config/'
$vagrantHosts = $configPath + "hosts/"
$hostFile = "/HOST"

#variable de chemin des fichiers
$hostPath = $configPath + $hostFile

Write-Output "`nClients dans hosts`n"
$validName = Get-ChildItem -Path $vagrantHosts -Name

if {$validName.Count -eq 0} {
    Write-Output "Aucun fichier de références n'exister dans Opération annulé"

}
$validName = $validNames -join ', '

$exitOption = "-q"

do {
    Write-Output "Noms de clients valides: $validName"
    $client = Read-Host -Prompt "Insérer le nom du client que vous voulez retirer du fichier HOST de Ansible ('$exitOption' pour quitter)"

    if ($client -eq $exitOption) {
        Write-Output "Opération annulé"
        exit
    }
    
} until ($validNames -contains $client)

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
