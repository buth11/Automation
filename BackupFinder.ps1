#Find backup files stored on local disk after certain date
#1.Identify local disk
Get-PSDrive #doesn't show which is hard drive

#We have to query WMI to work this out properly
get-wmiobject Win32_LogicalDisk | Where-Object DriveType -eq 3

#We need paramiters and join everyting together

$sinceDate = (Get-Date).AddDays(-330)
#$sinceDate = Get-Date("2020-05-01")
$backuFileTypes = @("*.bak","*.bck")

Get-WmiObject Win32_LogicalDisk | 
Where-Object DriveType -eq 3 | Select-Object -ExpandProperty DeviceID |
    Join-Path -ChildPath "\" | %{
        $driveRoot=$_
        Get-ChildItem $driveRoot -Include $backuFileTypes -Recurse -ErrorAction:SilentlyContinue | Where-Object {
            $_.CreationTime -ge $sinceDate
        }
    }


#Remote backu finder
Set-StrictMode -Version Latest

function Get-FilesByExtension (
    $sinceDate,
    $FindMatchingStrings = @("*.bak","*.bck")
) {
    Set-StrictMode -Version Latest

    Get-WmiObject Win32_LogicalDisk | Where-Object DriveType -eq 3 | Select-Object -ExpandProperty DeviceID |
        Join-Path -ChildPath "\" | %{
            $driveRoot=$_
            Write-Host "Scanning $driveRoot on $($env:COMPUTERNAME) for files like $($FindMatchingStrings) since $sinceDate"
            Get-ChildItem $driveRoot -Include $FindMatchingStrings -Recurse -ErrorAction:SilentlyContinue | Where-Object {
                $_.CreationTime -ge $sinceDate
            }
            #It already adds a PSComputerName property, but we could ...
            # | Select-Object -Property * #, @{Name = "ServerName"; Expression = {#env:COMPUTERNAME}}
        }
   }

   $serverNames = @("it01","za02")
   $sinceDate = Get-Date("2020-05-01")
   $results = @()
   
   #note that we don't use comma between paramiters here...
   #Get results from my PC
   $results+=Get-FilesByExtension $sinceDate @("*.bak","*.bck","*.txt") | select-object -property *, @{Name = "PSComputerName"; Expression = {$env:COMPUTERNAME}}

   #Get results from remote PC's
   $results += Invoke-Command $serverNames ${function:Get-FilesByExtension} -ArgumentList $sinceDate, @("*.bak","*.bck","*.txt")

   #Export results to csv
   $results | Select-Object -Property PSComputerName, FullName, CreationTime | Export-Csv -Path C:\tmp\results.csv -NoTypeInformation

   