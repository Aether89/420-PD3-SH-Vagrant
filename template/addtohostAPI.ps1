<# Script pour pouvoir associer un domain a une ip dans le fichier host du systeme hôte #>
$hostContent = {{HOSTSINFO}};
   
if ($IsWindows) {
    #Requires -RunAsAdministrator
    Add-Content -Path  "C:/Windows/System32/drivers/etc/hosts" -Value $hostContent
}
else {
    $hostContent | sudo tee -a "/etc/hosts"
}