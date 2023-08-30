<#
Script pour automatiser le processus de création de VagrantFile et pour Ansible
#>

# Vérifie si le dossier existe, sinon le crée
function createIfNotExist {
    param (
        [string]$path
    )
    if (!(Test-Path $path)) { 
        mkdir $path
    }
}

# Incrément l'IP
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

# Dossier Racine pour la localisation des scripts et fichiers
if ($IsWindows) {
    $installPathOS = "C:/"
}
else {
    $installPathOS = "~/"
    $syshostsPath = "/etc/hosts"
}

#nombre de VM dans le VagrantFile
$vmNumber = 3;

$client = Read-Host -Prompt 'Insérer le nom du client'

# génére  $installPath et si les dossier n'existee pas les crée
$paths = @('travail', 'commun', 'config', $client)
$installPath = $installPathOS
foreach ($path in $paths) {
    $installPath = $installPath + $path + '/'
    createIfNotExist -path $installPath
}

#variable de nom de fichier utiliser dans le script
$hostFile = "/HOST"
$VagrantFile = "/VagrantFile"
$addtohostfile = "addtohost.ps1"
$winHostFile = "winhost.ps1"

#variable de chemin  utiliser dans le script
$commonPath = $installPathOS + 'travail/commun/'
$configPath = $commonPath + 'config/'
$templatePath = $commonPath + "template/"
$vagrantHosts = $configPath + "hosts/"


#variable de chemin des fichiers
$ipPath = $commonPath + "next.txt"
$templateVagrantPath = $templatePath + $VagrantFile
$playbookPath = $templatePath + "playbook"
$hostPath = $configPath + $hostFile
$vagrantPath = $installPath + $VagrantFile
# $clienthostPath = $installPath + $hostFile
$addtohostPath = $installPath + $addtohostfile
$vagrantHostsFile = $VagrantHosts + $client

#utiliser pour le fichier HOST de Ansible
$bracketClient = "[$client]"

#copie les playbook de templates dans le dossieer du client
Copy-Item $playbookPath $installPath

# Obtien la derniere address IP de next.txt puis incrémente 
# les address et les mets à jours dans le VagrantFile
# qui est mis dans le dossier client.
$IPv4 = Get-Content $ipPath
$fileContent = Get-Content -Path $templateVagrantPath -Raw

Add-Content -Path $hostPath -Value $bracketClient
createIfNotExist -path $vagrantHosts
Add-Content -Path $vagrantHostsFile -Value $bracketClient

for ($i = 0; $i -lt $vmNumber; $i++) {
    $stringToReplace = "{{IP" + ($i + 1) + "}}"

    $newIP = (ipUpdate -ip $IPv4 -increment $i)
    Add-Content -Path $hostPath -Value $newIP
    Add-Content -Path $vagrantHostsFile -Value $newIP

    $fileContent = $fileContent -replace $stringToReplace, $newIp

    # mets an mémoire les deux première ip pour 
    # l'ajout dans le fichier hosts
    switch ($i) {
        1 { $httpdIP = $newIP }
        2 { $apiIP = $newIP }
    }
}
#sauvegarde le VagrantFile dans le dossier du client
$fileContent | Set-Content -Path $vagrantPath

# Mets à jours le contenue de next.txt 
Set-Content -Path $ipPath -Value (ipUpdate -ip $IPv4 -increment ($vmNumber))


# Génere le contenue qui sera ajouter au hôte
$hostContent = "`n$httpdIP `t$client.com`n$apiIP `tapi.$client.com"
# Copie le fichier template addtohost en mémoire, 
$fileContent = Get-Content -Path $templatePath$addtohostfile -Raw
# remplace {{HOSTINFO}} avec le contenue de $hostconteent
$fileContent = $fileContent -replace "{{HOSTSINFO}}", "`"$hostContent`""
# créer le fichier  C:/travail/commun/config/$client/addtohost.ps1
$fileContent | Set-Content -Path $addtohostPath
Write-Output "Un script permettant de faire l'ajout de $client.com et api.$client.com`nau fichier hosts de l'hôte a été ajouté dans $addtohostPath"  

# Prompt pour demander à l'utilisatueur si veut ajouter 
# client.com et api.client.com au fichier hosts du systeme
$Cursor = [System.Console]::CursorTop
Do {
    [System.Console]::CursorTop = $Cursor
    $addHost = Read-Host -Prompt "Voulez-vous faire les ajoûts dans le fichier hosts maintenant?(y/n)"
}
Until ($addHost -eq 'y' -or $addHost -eq 'n')

# Demande si veut ajouter au fichier hosts dy systeme d'operation
if ($addHost -eq 'y') {

    if ($IsWindows) {

        $fileContent = Get-Content -Path $templatePath$winHostFile -Raw
        $fileContent = $fileContent -replace "{{HOSTSINFO}}", "`"$hostContent`""
        $fileContent | Set-Content -Path $commonPath$winHostFile

        Read-Host -Prompt "Une nouvelle fenêtre s'ouvrira pour faire 
        l'ajout dans le fichier host`nSi demander, Accepter pour faire l'ajout.
        appuyer sur Entrée pour continuer"
        # execute le fichier dans fenetre avec les permision administrateur.
        # Doit écrire le chemin au complet car ne fonctionne pas avec des variables 
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"C:/travail/commun/winhost.ps1`"" -Verb runAs
    }
    else {
        Write-Output "Veuillez entrez votre mots de passe pour faire l'ajout dans le fichier hosts."        
        $hostContent | sudo tee -a $syshostsPath
    }
}