#Create trext file
Set-Content -Path "test.txt" -Value "This is a test"

#Show help in a window
get-help Set-Content -ShowWindow

#String variable with multi lines

$myVariable =@"
1.Line
2.Line
3.Line
"@

$myVariable2 = " `
test `
test"

#Show all variables starting with 'm'
Get-Variable m*

#code, when you run nothing happens
{1+1}

#add '.' or '&' to execute
.{1+1} # &{1+1}
& notepad

# '&' and '.' are not equivalent, 
$myVariable = 1

#myVariable is 2 only inside bloc{ } but outside is still = 1
. {$myVariable +=1}
"myVariable is now $myVariable"

#myVariable will by = 2 even outsiade block { }
& {$myVariable +=1}
"myVariable is now $myVariable"

#you can turn string into block of code
$myVariable = [scriptblock]::Create("1+1")

#everything is an object
([int] "1").GetType()
([int] "1").tostring().GetType()

#Array
"First Item", "Second Item"

@("First Item") #Array with one item to have possibility to add more items (otherwise is a string)

#select First Item
("First Item", "Second Item")[0]

#Properties .Count, GetType() etc.

#Hash table have only two paramiters Name:Value
@{Item1 = "Value 1"
  Item2 = "Value 2"}

$myVariable= @{ Item1 = "Value 1"
Item2 = "Value 2"}

$myVariable["Item2"]

#Splating

$myVariable = @{
    Path = "C:\tmp\test.txt"
    Value = "Hi"
}

#Set-Content of file test.txt to "Hi" 
Set-Content @myVariable
Get-Content C:\tmp\test.txt

#this create a .NET object from hash table
$myVariable =[pscustomobject] @{
  Line1="This is"
  Line2="a hash table"
}
$myVariable
$myVariable.Line1

#Be careful with dates, they are represented internaly as US format
$myVariable = [datetime] "2020-05-20"
$myVariable
$myVariable.ToString()
"oops: $myVariable"
"Use this instead: $($myVariable.ToString())"

#<----Pipes---->
1,2,3,4,5,6,7 | Select-Object -First 3
1,2,3,4,5,6,7 | Select-Object -Last 2
1,2,3,4,5,6,7 | Measure-Object -Average -Sum -Maximum -Minimum

#Select-Object to grab just parts of objects
$myVariable | Select-Object Line1

#And %{ is for Each Loop where $_ is being iterated}
1, 2 | %{
  "Received $_"
}
#Same thing
foreach ($myNumber in @(1, 2)){
  "Received $myNumber"
}

#Where-Object is common and powerful command that takes a block.
#This also show some comparison operators too, you can't use ==, >, < etc.
1,2 | Where-Object {$_ -eq 1} #Equal
1,2 | Where-Object {$_ -gt 1} #Greater than
1,2 | Where-Object {$_ -lt 1} #Less than

#Default "varables"

Get-Variable *Ver*
$PSVersionTable

#Enviroment varaibles $env:ComputerName
$env:APPDATA
$env:ComputerName
Get-ChildItem env: #shows all atributes of env:
Set-Item myEnvirementVariable "Great!"
#Inspect our varable
$env:myEnvirementVariable

#Some commands you can execute if they are in your path
ping localhost -n 1

#Or run them if you are in specyic directory
C:\Windows\system32\ping localhost -n 1

#We can use variables, too
ping $env:COMPUTERNAME -n 1

#We can run commands dynamically
$myCommand = "ping"
&$myCommand $env:ComputerName -n 1

#Let's deal with some errors!
$myCommand = "pign"
&$myCommand $env:ComputerName -n 1

try {
  &$myCommand $env:ComputerName -n 1
}
catch {
  # $_ is the "last error". It's best to quicly save it.
  $thisError = $_

  #Now we can do anything, or...
  "You're out! Why? $($thisError.Exception.Message)"
}

#That works only on terminating errors

Copy-Item test.txt c:\

try {
  Copy-Item test.txt c:\
}
catch {
  "You will never catch me!"
}

$ErrorActionPreference = "Stop"
try {
  Copy-Item test.txt c:\
}
catch {
  "You will never catch me!"
}
#You could also Copy-Item Test.txt c:\ -ErrorAction:Stop

#<------------------ I/O -------------------------->
#Basic IO
$myInput = Read-Host "Tell me something"

Write-Host $myInput   #It's a lot like PRINT
Write-Output $myInput #It's a lot like SELECT

$myOutput = Write-Host $myInput
"MyOutput is: $myOutput" #Blank
$myOutput = Write-Output $myInput
"MyOutput is: $myOutput" #Not on your life

$myInput | Clip #Pipleline it to Clipborad
&notepad        #Now we can past it to for ex. to notepad

#We can write out all the files in our Windows dir into a CSV
$myFiles = Get-ChildItem C:\Windows
$myFiles | Measure-Object
$myFiles | ConvertTo-Csv | Set-Content c:\tmp\MyWindowsFiles.csv

#It is a lot columns
&notepad C:\tmp\MyWindowsFiles.csv

#We can recreate object from CSV
$myFiles = $null
$myFiles = Get-Content C:\tmp\MyWindowsFiles.csv | ConvertFrom-Csv

#Get just columns we want
$myFiles | Select-Object -Property Name, Attributes | ConvertTo-Csv | Set-Content C:\tmp\MyWindowsFiles.csv


#XML are more complicated so we need to Import-CliXml cmdlet
$myFiles | Select-Object -Property Name, Attributes | Export-Clixml C:\tmp\MyWindowsFiles.XML
&notepad C:\tmp\MyWindowsFiles.xml

#similar command than that above
$myFiles | Select-Object -Property Name, Attributes | ConvertTo-Xml | Select-Object -ExpandProperty OuterXml | Set-Content C:\tmp\MyWindowsFiles.XML
&notepad C:\tmp\MyWindowsFiles.xml


#<--------------BASIC INVESTIGATION---------------------->
#This is creating super long path until it break
$dirName = "C:\tmp"
$subDirName = "1234567890"
try {
  while($true){
    $dirName=Join-Path $dirName $subDirName
    md $dirName
  }
}
catch {
  "We got up to $dirName"
  rd "c:\tmp\$subDirName" -Recurse
}

#VARIABLE
$myVariable = Get-ChildItem c:\Windows

#What do we have?
$myVariable.GetType()
$myVariable.Count
$myVariable | Measure-Object
$myVariable[0].GetType()

#Get-Member is extremely important command for finding information

$myVariable | Get-Member

#If we want to know what just array can do
Get-Member -InputObject $myVariable

#If we want to know file name
$myVariable
$myVariable.name

#If we want to know commands with name or path
$myVariable | Get-Member *Path*
$myVariable | Get-Member *Name*

$myVariable.FullName

#Other way is
$myVariable | Select-Object -Property FullName
$myVariable | Select-Object -Property FullName, extension

#We can create own property
$myVariable | Select-Object -Property FullName, extension,
@{ Name="Just Extension"; Expression = {$_.Extension.Substring(1)}}

#And Pipe that to for ex. Sory
$myVariable | Select-Object -Property FullName, extension,
@{ Name="Just Extension"; Expression = {$_.Extension.Substring(1)}} | Sort-Object -Property "Just Extension" -Descending

#To get help use:
Get-help Get-ChildItem -ShowWindow

#Let's pass a path and filter
Get-ChildItem c:\Windows

Get-ChildItem c:\Windows | Get-Member

#Directories
Get-ChildItem c:\Windows |
  Where-Object {$_ -is [System.IO.directoryinfo]}

  #Files
Get-ChildItem c:\Windows |
Where-Object {$_ -isnot [System.IO.directoryinfo]}

# ! is also supported
Get-ChildItem c:\Windows |
  Where-Object {! $_ -is [System.IO.directoryinfo]}

#What is the longest path on disk that doesn't have files in it?
Get-ChildItem c:\ -Recurse -Directory -ErrorAction:SilentlyContinue |
Sort-Object {$_.FullName.Length} -Descending |
Where-Object {
  (Get-ChildItem $_.FullName -file | Measure-Object).Count -eq 0 
} | Select-Object -First 1