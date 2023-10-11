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

function createAZVM {
    param (
        [string] $name
    )
$resourceGroupName = $myOrg + "Production"
$vmName = $client + "-" + $name
$netName = $client + "-vnet"
$ipName = $vmName + "IP"
$subnetName = $client + "-subnet"
$adminUser = Read-Host -Prompt 'Insérer le nom du compte Administrateur'
$passPrompt = Read-Host -Prompt 'Insérer le mots de passe du compte Administrateur'
$adminPass = ConvertTo-SecureString -String $passPrompt -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminUser, $adminPass

new-azvm -ResourceGroupName $resourceGroupName -Name $vmName -ImageName $vmOS -Size $vmSize -location $vmLocation -VirtualNetworkName $netName -publicIpAddressName $ipName  -SubnetName $subnetName -OpenPorts 22,80,443 -Credential $credential 
$ipResult = Get-AzPublicIPAddress -Name $ipName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty IpAddress

$myObject = New-Object -TypeName PSObject -Property @{
    admin = $adminUser
    ip = $ipResult
}
return $myObject
}

# Variale de configuration pour les machines virtuelles
$vmOS = "Ubuntu2204"
$vmSize = "Standard_B1ls"
$vmLocation = "canadacentral"
$myOrg = "NewTech"
$pushedCommits = "https://github.com/Aether89/NewTech-Default"
#variable de nom de fichier utiliser dans le script
$date = Get-Date -Format "yyyy-MM-dd HH:mm"

$hostFile = "/HOSTS"
$VagrantFile = "VagrantFile"
$srcFile = "src"
$gitignoreFile = ".gitignore"
$readmeFile = "README.md"
$addtohostfile = "addtohost.ps1"
$winHostFile = "winhost.ps1"
$apiPB = "api-install.yml"
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

# génére  $installPath et si les dossier n'existe pas les crée
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
$readmePath = $clientPath + "/" + $readmeFile
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

Copy-Item -Path $templatePath$srcFile\* -Destination $clientPath -Recurse -Force
Copy-Item -Path $templatePath$gitignoreFile -Destination $gitignorePath
Copy-Item -Path $templatePath$readmeFile -Destination $readmePath

replaceInFile -fileInput $readmePath -toReplace "{{DATE}}" -replacement $date 
replaceInFile -fileInput $readmePath -toReplace "{{CLIENT}}" -replacement $client 

# remplace {{CLIENT} dans les fichiers playbook avec le nom du client
replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{CLIENT}}" -replacement $client 
replaceInFile -fileInput $clientPlaybookPath$updatePB -toReplace "{{CLIENT}}" -replacement $client 

# Connection à Azure
Write-Output "Veuillez vous connecter à Azure"
connect-azaccount

# HTTPD
Write-Output "Création de la VM HTTPD"
$httpdIP = createAZVM -name "httpd"

# API
write-Output "Création de la VM API"
$apiIP =CreateAZVM -name "api"

# DB 
Write-Output "Création de la VM DB"
$dbIP = CreateAZVM -name "db"

Add-Content -Path $hostPath -Value $bracketClient
createIfNotExist -path $vagrantHosts
Add-Content -Path $vagrantHostsFile -Value $bracketClient

for ($i = 0; $i -lt $vmNumber; $i++) {
    $stringToReplace = "{{IP" + ($i + 1) + "}}"

    switch ($i) {
        0 {
            Add-Content -Path $hostPath -Value $httpdIP.ip
            Add-Content -Path $vagrantHostsFile -Value $httpdIP.ip
        
            replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace $stringToReplace -replacement $httpdIP.ip
            replaceInFile -fileInput $clientPlaybookPath$httdPB -toReplace $stringToReplace -replacement $httpdIP.ip
        }
        1 {
            Add-Content -Path $hostPath -Value $apiIP.ip
            Add-Content -Path $vagrantHostsFile -Value $apiIP.ip
        
            replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace $stringToReplace -replacement $apiIP.ip
            replaceInFile -fileInput $clientPlaybookPath$apiPB -toReplace $stringToReplace -replacement $apiIP.ip
        }
        2 {
            Add-Content -Path $hostPath -Value $dbIP.ip
            Add-Content -Path $vagrantHostsFile -Value $dbIP.ip
        
            replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace $stringToReplace -replacement $dbIP.ip
            replaceInFile -fileInput $clientPlaybookPath$dbinstallPB -toReplace $stringToReplace -replacement $dbIP.ip
        }
    }
}

replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{HTTPDADMIN}}" -replacement $httpdIP.admin
replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{APIADMIN}}" -replacement $apiIP.admin
replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{DBADMIN}}" -replacement $dbIP.admin

replaceInFile -fileInput $clientPlaybookPath$httdPB -toReplace "{{HTTPDADMIN}}" -replacement $httpdIP.admin
replaceInFile -fileInput $clientPlaybookPath$apiPB -toReplace "{{APIADMIN}}" -replacement $apiIP.admin
replaceInFile -fileInput $clientPlaybookPath$dbinstallPB -toReplace "{{DBADMIN}}" -replacement $dbIP.admin

#sauvegarde le VagrantFile dans le dossier du client
$fileContent | Set-Content -Path $vagrantPath

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

# Demande si veut ajouter au fichier hosts du systeme d'operation
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

Set-Location $clientPath

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
write-host "$pushedCommits.git"
}

replaceInFile -fileInput $clientPlaybookPath$httdPB -toReplace "{{GITHUB}}" -replacement "$pushedCommits.git"
replaceInFile -fileInput $clientPlaybookPath$httdPB -toReplace "{{CLIENT}}" -replacement $client

Set-Location $commonPath