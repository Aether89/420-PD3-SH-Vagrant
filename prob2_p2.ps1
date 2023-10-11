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
#variable de nom de fichier utiliser dans le script

$hostFile = "/HOSTS"
$addtohostfile = "addtohostAPI.ps1"
$winHostFile = "winhost.ps1"
$apiPB = "api-install.yml"
$dbInstallPB = "db-install.yml"
$setupPB = "setup_p2.sh"
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
$templateClientPath = $templatePath + "client"
$playbookPath = $templatePath + "playbook_p2"
$clientPlaybookPath = $installPath + "playbook/"
$hostPath = $configPath + $hostFile
$clientPath = $workPath + $client
$addtohostPath = $installPath + $addtohostfile
$vagrantHostsFile = $VagrantHosts + $client

Write-Output $clientPath
createIfNotExist -Path $clientPath

Copy-Item -Path "$templateClientPath\*" -Destination $installPath -Recurse

#copie les playbook de templates dans le dossieer du client
Copy-Item -r $playbookPath $installPath

# remplace {{CLIENT} dans les fichiers playbook avec le nom du client
replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{CLIENT}}" -replacement $client 
replaceInFile -fileInput $clientPlaybookPath$updatePB -toReplace "{{CLIENT}}" -replacement $client 

# Connection à Azure
Write-Output "Veuillez vous connecter à Azure"
connect-azaccount

# API
write-Output "Création de la VM API"
$apiIP =CreateAZVM -name "api"

# DB 
Write-Output "Création de la VM DB"
$dbIP = CreateAZVM -name "db"

createIfNotExist -path $vagrantHosts

            Add-Content -Path $hostPath -Value $apiIP.ip
            Add-Content -Path $vagrantHostsFile -Value $apiIP.ip
        
            replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{IP2}}" -replacement $apiIP.ip
            replaceInFile -fileInput $clientPlaybookPath$apiPB -toReplace  "{{IP2}}" -replacement $apiIP.ip

            Add-Content -Path $hostPath -Value $dbIP.ip
            Add-Content -Path $vagrantHostsFile -Value $dbIP.ip
        
            replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{IP3}}" -replacement $dbIP.ip
            replaceInFile -fileInput $clientPlaybookPath$dbinstallPB -toReplace "{{IP3}}" -replacement $dbIP.ip


replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{APIADMIN}}" -replacement $apiIP.admin
replaceInFile -fileInput $clientPlaybookPath$setupPB -toReplace "{{DBADMIN}}" -replacement $dbIP.admin

replaceInFile -fileInput $clientPlaybookPath$apiPB -toReplace "{{APIADMIN}}" -replacement $apiIP.admin
replaceInFile -fileInput $clientPlaybookPath$dbinstallPB -toReplace "{{DBADMIN}}" -replacement $dbIP.admin

# Mets a jours api-install.yml
$fileContent = Get-Content -Path $templatePath$addtohostfile -Raw

# Génere le contenue qui sera ajouter au hôte
$hostContent = "`n$apiIP `tapi.$client.com"
# Copie le fichier template addtohost en mémoire, 
$fileContent = Get-Content -Path $templatePath$addtohostfile -Raw
# remplace {{HOSTINFO}} avec le contenue de $hostconteent
$fileContent = $fileContent -replace "{{HOSTSINFO}}", "`"$hostContent`""
# créer le fichier  C:/travail/commun/config/$client/addtohost.ps1
$fileContent | Set-Content -Path $addtohostPath
Write-Output "Un script permettant de faire l'ajout de api.$client.com`nau fichier hosts de l'hôte a été ajouté dans $addtohostPath"  

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