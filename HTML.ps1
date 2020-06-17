Get-ChildItem c:\tmp | Select-Object -Property FullName, Length, CreationTime, Attributes | ConvertTo-Html | Set-Content c:\tmp\convertToHtml.html
&explorer.exe C:\tmp\convertToHtml.html

#Much Better
Install-Module -Name pshtmltable

Import-Module pshtmltable -Force

$htmlBody = Get-ChildItem C:\tmp | Select-Object -Property FullName, Length, CreationTime, Attributes | New-HTMLTable
Close-HTML "$(New-HTMLHead)$htmlBody" | Set-Content c:\tmp\htmlTable.html
&explorer.exe C:\tmp\htmlTable.html

#Or even better with other version of module HTMLTable
$htmlBody = Get-ChildItem c:\tmp |Select-Object -Property FullName, Length, CreationTime, Attributes | 
    New-HTMLTable -setAlternating:$true -columnStyle @{
            Column = "Length"
            Style = "right"
    }, @{
            Column = "CreationTime"
            Style = "right"
    } |
Add-HTMLTableColor Attributes -like "Directory" -AttrValue "colour:white;background-colour:#6699FF;" -WholeRow | 
Add-HTMLTableColor Length -gt 38000 -AttrValue "background-colour:orange;"

Close-HTML "$(New-HTMLHead)$htmlBody" | Set-Content c:\tmp\htmlTableHighlights.html
&explorer.exe C:\tmp\htmlTableHighlights.html