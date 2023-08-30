<# Script pour pouvoir associer un domain a une ip dans le fichier host du systeme hôte #>
$hostContent = "
192.168.33.38 	.com
192.168.33.39 	api..com";
   
if ($IsWindows) {
    #Requires -RunAsAdministrator
    Add-Content -Path  "C:/Windows/System32/drivers/etc/hosts" -Value $hostContent
}
else {
    $hostContent | sudo tee -a "/etc/hosts"
}
