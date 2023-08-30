<# Script pour ajouter au fichier host de windows lorsque appeller via un autre script#>
# {{HOSTINFO}} est remplacer par la valeur désiré car les variable ne semble pas fonctionner si
# appeller via un autre script
Add-Content -Path  "C:/Windows/System32/drivers/etc/hosts" -Value {{HOSTSINFO}}
Remove-Item -Force C:/travail/commun/winhost.ps1