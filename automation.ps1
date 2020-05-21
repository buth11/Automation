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