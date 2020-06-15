Get-ChildItem c:\tmp | Select-Object -Property FullName, Length, CreationTime, Attributes | ConvertTo-Html | Set-Content c:\tmp\convertToHtml.html
&explorer.exe C:\tmp\convertToHtml.html

#Much Better
Install-Module -Name pshtmltable

Import-Module pshtmltable -Force

$htmlBody = Get-ChildItem C:\tmp | Select-Object -Property FullName, Length, CreationTime, Attributes | New-HTMLTable
Close-HTML "$(New-HTMLHead)$htmlBody" | Set-Content c:\tmp\htmlTable.html
&explorer.exe C:\tmp\htmlTable.html

#Or even better