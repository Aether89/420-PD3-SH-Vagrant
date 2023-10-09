<####################################
#   autheur: Aether89
#   descriiption: Script pour automatiser 
#   le processus de création de VagrantFile 
#   et playbook pour Ansible
###################################>

# Fonction pour Vérifier si le dossier existe, sinon le crée
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

function replaceInFile {
    param (
        [string]$fileInput,
        [string]$toReplace,
        [string]$replacement
    )
    
    $replaceInFileContent = Get-Content -Path $fileInput -Raw
    $replaceInFileContent = $replaceInFileContent -replace $toReplace, $replacement
    $replaceInFileContent | Set-Content -Path $fileInput
}

#variable de nom de fichier utiliser dans le script
$myOrg = "NewTech"
$hostFile = "/HOSTS"
$VagrantFile = "VagrantFile"
$srcFile = "src"
$gitignoreFile = ".gitignore"
$addtohostfile = "addtohost.ps1"
$winHostFile = "winhost.ps1"
$apiPB = "api-install.yml"
$dbAddUserPB = "db-add-user.yml"
$dbConfigurePB = "db-configure.yml"
$dbInstallPB = "db-install.yml"
$httdPB = "httpd-install.yml"
$setupPB = "setup.sh"
$updatePB = "update.yml"
$workDir = "travail/"
$commonDir = "commun/"
$configDir = "config/"
$templateDir = "template/"

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
$paths = @($workDir, $commonDir, $configDir, $client)
$installPath = $installPathOS
foreach ($path in $paths) {
    $installPath = $installPath + $path + '/'
    createIfNotExist -path $installPath
}

#variable de chemin  utiliser dans le script
$workPath = $installPathOS + $workDir
$commonPath = $installPathOS + $workDir + $commonDir
$configPath = $commonPath + $configDir
$templatePath = $commonPath + $templateDir
$vagrantHosts = $configPath + ".hosts/"

#variable de chemin des fichiers
$ipPath = $commonPath + "next.txt"
$templateClientPath = $templatePath + "client"
$playbookPath = $templatePath + "playbook"
$clientPlaybookPath = $installPath + "playbook/"
$hostPath = $configPath + $hostFile
$clientPath = $workPath + $client
$vagrantPath = $clientPath + "/" + $VagrantFile
$gitignorePath = $clientPath + "/" + $gitignoreFile
$srcPath = $clientPath + "/src"
### $clienthostPath = $installPath + $hostFile
$addtohostPath = $installPath + $addtohostfile
$vagrantHostsFile = $VagrantHosts + $client

Write-Output $clientPath
createIfNotExist -Path $clientPath

#utiliser pour le fichier HOST de Ansible
$bracketClient = "[$client]"
Copy-Item -Path "$templateClientPath\*" -Destination $installPath -Recurse -Force

#copie les playbook de templates dans le dossieer du client
Copy-Item -r $playbookPath $installPath


Copy-Item  -Path $templatePath$vagrantFile -Destination $vagrantPath
Copy-Item  -r -Path $templatePath$srcFile -Destination $srcPath
Copy-Item -Path $templatePath$gitignoreFile -Destination $gitignorePath

# remplace {{CLIENT} dans les fichiers playbook avec le nom du client
replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{CLIENT}}" -replacement $client 
replaceInFile -fileInput $clientPlaybookPath$updatePB -toReplace "{{CLIENT}}" -replacement $client 


# Obtien la derniere address IP de next.txt puis incrémente 
# les address et les mets à jours dans le VagrantFile
# qui est mis dans le dossier client.
$IPv4 = Get-Content $ipPath
$fileContent = Get-Content -Path $vagrantPath -Raw

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
        0 {
            $httpdIP = $newIP
            replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace $stringToReplace -replacement $newIP 
            replaceInFile -fileInput $clientPlaybookPath$httdPB -toReplace $stringToReplace -replacement $newIP 
        }
        1 {
            $apiIP = $newIP 
            replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace $stringToReplace -replacement $newIP 
            replaceInFile -fileInput $clientPlaybookPath$apiPB -toReplace $stringToReplace -replacement $newIP 
        }
        2 {
            replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace $stringToReplace -replacement $newIP 
            replaceInFile -fileInput $clientPlaybookPath$dbinstallPB -toReplace $stringToReplace -replacement $newIP 
            replaceInFile -fileInput $clientPlaybookPath$dbConfigurePB -toReplace $stringToReplace -replacement $newIP 
            replaceInFile -fileInput $clientPlaybookPath$dbAddUserPB -toReplace $stringToReplace -replacement $newIP 
        }
    }
}
#sauvegarde le VagrantFile dans le dossier du client
$fileContent | Set-Content -Path $vagrantPath

# Mets à jours le contenue de next.txt 
Set-Content -Path $ipPath -Value (ipUpdate -ip $IPv4 -increment ($vmNumber))

# Mets a jours api-install.yml
$fileContent = Get-Content -Path $templatePath$addtohostfile -Raw


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

cd $clientPath
$date = Get-Date -Format "yyyy-MM-dd HH:mm"
$readmeContent = "# Read Me $client
$date
## Prérequis
- vagrant
- azure 
- git
- github cli
"

Set-Content -Path "$clientPath/README.md" -Value $readmeContent

git init
git add .
git commit -m "Initial commit"

Do {
    [System.Console]::CursorTop = $Cursor
    $commitGitHub = Read-Host -Prompt "Voulez-vous pousser le répertoire sur GitHub?(y/n)"
}
Until ($commitGitHub -eq 'y' -or $commitGitHub -eq 'n')

if ($commitGitHub -eq 'y') {
$response = gh repo create "$myOrg-$client" --public --source $clientPath --push
$pushedCommits = $response -split "branch" | Select-Object -First 1
write-host "rsult"
write-host "$pushedCommits.git"
}

cd $commonPath
