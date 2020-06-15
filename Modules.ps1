

Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force

#Modules are sored
$env:PSModulePath

$modulePath = ($env:PSModulePath -split ";")[0]
$myModulePath = "$modulePath\MyModule"

if (!(Test-Path $myModulePath)) {
    mkdir $myModulePath | Out-Null #We don't need to create them individually
}

#Create a PSM1 file
New-ModuleManifest "$myModulePath\MyModule.psd1" -Author "Bartosz Suszko" -RootModule "MyModule.psm1"
&notepad.exe "$myModulePath\MyModule.psd1"

#This one just loads alle the other functions
Set-Content "$myModulePath\MyModule.psm1" 'Get-ChildItem -path $PSScriptRoot\*.ps1 | %{ . $_.FullName }'
&notepad.exe "$myModulePath\MyModule.psm1"

Set-Content "$myModulePath\Test-MyModule.ps1" 'function Test-MyModule { Write-Host "Yes, it loaded ok!" }'
Import-Module MyModule -Force #Force is important
Test-MyModule

<# Mało istotne----------
Get-Help Test-MyModule
Copy-Item "$env:USERPROFILE\desktop\Test-MyModule.ps1" "$myModulePath"
&notepad.exe "$myModulePath\test-mymodule.ps1"

Import-Module MyModule -Force
Get-Help Test-MyModule -Full
#>

#Profiles
$profile
Get-Content $profile

if (!(Test-Path (Split-Path $profile))) {
    mkdir (Split-Path $profile)
}

Set-Content $profile @"
Set-StrictMode -Version Latest
Import-Module MyModule -Force
"@

