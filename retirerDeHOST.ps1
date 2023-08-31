<####################################
#   autheur: Aether89
#   descriiption: Script pour supprimer
#   des Clients/IP du fichier HOST
#   d'Ansible
###################################>


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
$hostFile = "HOSTS"

#variable de chemin des fichiers
$hostPath = $configPath + $hostFile
$exitOption = "-q"

do {
do {
    $validName = Get-ChildItem -Path $vagrantHosts -Name

    if ($validName.Count -le 0) {
        Write-Output "Dossier .hosts vide, Opération annulé"
        exit
    }
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

$contentToClean
$newContent = @()
foreach ($line in $contentToClean) {
    if ($contentToRemove -notcontains $line) {
        $newContent += $line
    }
}
$newContent | Set-Content -Path $hostPath
Remove-Item $vagrantHostsFile
Write-Output "Fichier HOST Nettoyer"

} Until ($client -eq $exitOption)