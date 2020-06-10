<#REMOTING
Enable-PSRemoting
AllowUnencrypted
TrustedHosts
Invoke-Command and Enter-PSSession
#>

#Turn on Remoting
Enable-PSRemoting
$allowUnencrypted = "WSMan:\localhost\Client\AllowUnencrypted"
Get-ChildItem $allowUnencrypted
Set-Item $allowUnencrypted $true
$trustedHosts = "WSMan:\localhost\Client\TrustedHosts"
Get-ChildItem $trustedHosts
Set-Item $trustedHosts *

#If you whant do it on localhost you need to be As Admin
Invoke-Command . { dir c:\}

#Other PC
Invoke-Command it01 { dir c:\}

#We can pass paramiters
$driveName = "C:\"
Invoke-Command it01 {Dir $using:driveName}

#Another way to pass paramiters
Invoke-Command it01 {
    param (
        $driveName
    )
    dir $driveName
} -ArgumentList $driveName

#Active session
Enter-PSSession it01

#Test Connection
Test-Connection bujalski-master -Count 1

#We can control it
Invoke-Command bujalski-master.bujalski.local {dir c:\} -Authentication Negotiate -Credential (Get-Credential "Administrator")







