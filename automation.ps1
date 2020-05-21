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