#What you get in the box
Import-Module SQLPS -DisableNameChecking #OutDated

#Actual
Install-Module -Name SqlServer
Update-Module -Name SqlServer
Uninstall-Module -Name SqlServer

Import-Module SqlServer
cd SqlServer:

Get-Command -Module SqlServer | Where-Object {$_.Name -like '*con*'}

#An irritating path change... something

dir

# Only local discovery

Dir SQL
Dir SQL\IT02

#This works
cd SQL\IT02\default
cd SQL\IT02\SQLEXPRESS

dir Logins

Dir Logins | Select-Object *

dir DATABASES -Force

dir DATABASES\master\Users

#Doesn't work because Set-Item is not supported
Set-Item Anything $true

cd \

# And it required your account to have WMI authentication
dir SQL\biosys\default

##Change network conection

# What about quering data?

C:

# This works great!

$myVariable = Invoke-Sqlcmd -Server IT02 "Select * from sys.syslogins"
$myVariable | Select-Object -First 1

# This not so much
# Properities are Mixedup
$sqlCommand = "Select * from sys.syslogins; Select * from sys.dm_exec_sessions; Print 'Hi'"
$myVariable = Invoke-Sqlcmd -server IT02 $sqlCommand
$myVariable | Select-Object -First 1
$myVariable | Select-Object -Last 1

#This disappears

Invoke-Sqlcmd -ServerInstance IT02 "Print 'Hi'"

# Until you do this
Invoke-Sqlcmd -ServerInstance IT02 "Print 'Hi'" -Verbose

#You can't trap Verbose output
$myVariable=Invoke-Sqlcmd -Server IT02 "Print 'Hi'" -Verbose
$myVariable

#Or you can ( 4>&1 )
$myVariable=Invoke-Sqlcmd -Server IT02 "Print 'Hi'" -Verbose 4>&1
$myVariable

#But there are still bugs (not anymore)
$myVariable=Invoke-Sqlcmd -Server IT02 "Print 'Hi'" -Verbose -IncludeSqlUserErrors 4>&1
$myVariable

#---------------CONNECTION TEST-----------------------------------
try
{
    # This is a simple user/pass connection string.
    # Feel free to substitute "Integrated Security=True" for system logins.
    $connString = "Data Source=IT02;Database=Biosystem;User ID=sa;Password=But**er***5"

    #Create a SQL connection object
    $conn = New-Object System.Data.SqlClient.SqlConnection $connString

    #Attempt to open the connection
    $conn.Open()
    if($conn.State -eq "Open")
    {
        # We have a successful connection here
        # Notify of successful connection
        Write-Host "Test connection successful"
        $conn.Close()
    }
    # We could not connect here
    # Notify connection was not in the "open" state
}
catch
{
    # We could not connect here
    # Notify there was an error connecting to the database
    Write-Host "Test connection unsuccessful"
}
#-----------------------------------------------------------------------

#Create SQL Server login
# To run in a non-interactive mode, such as through an Octopus deployment, you will most likely need to pass the new login credentials as a PSCredential object.
$pass = ConvertTo-SecureString "Butcher1985" -AsPlainText -Force

# Create the PSCredential object
$loginCred = New-Object System.Management.Automation.PSCredential("buth",$pass)

# Create login using the Add-SqlLogin cmdlet
Add-SqlLogin -ServerInstance IT02 -LoginPSCredential $loginCred -LoginType SqlLogin -Enable

# Create SQL Server database
Invoke-Sqlcmd -Query "CREATE DATABASE YourDB" -ServerInstance IT02

#Name your database
$dbname = "YourDB3"
# Create a SQL Server database object
$srv = New-Object Microsoft.SqlServer.Management.Smo.Server("IT02")
if($null -eq $srv.Databases[$dbname])
{
    $db = New-Object Microsoft.SqlServer.Management.Smo.Database($srv, $dbname)

    # Create the database
    $db.Create()
}

#--------------CHANGE OWNER-------------------------
# Restore-SqlDatabase cmdlet is your friend:
$backupFile = "\\SQLBackups\YourDBBackup.bak"
Restore-SqlDatabase -ServerInstance IT02 -Database Biosystem -BackupFile $backupFile

# Here we'll need a user with administrative privileges to set the owner.
# Let's say that $SqlAdmin contains the username and $SqlAdminPass contains the password as a secure string.
$dbname = "YourDB"

# Create the server connection object
$conn = New-Object Microsoft.SqlServer.Management.Common.ServerConnection("YourInstance", $SqlAdmin, $SqlAdminPass)

# Create the server object
$srv = New-Object Microsoft.SqlServer.Management.Smo.Server($conn)

# Check to see if a database with that name already exists
if($null -ne $srv.Databases[$dbname])
{
    # If it does not exist, create it
    $db = New-Object Microsoft.SqlServer.Management.Smo.Database($srv, $dbname)
    $db.SetOwner("NewOwner")
}
else
{
    # There was an error creating the database object
}
#----------------------------------------------------------


# Run a SQL script from a file
Invoke-Sqlcmd -InputFile .\alter_script.sql -ServerInstance IT02 -Database Biosystem

#Run inline SQL commands
$rowcount = "SELECT COUNT(*) FROM BS_USER"
$rowcount = "Select * from sys.syslogins;"
$rowcount = "Select * from sys.dm_exec_sessions;"

#Create Table
$createTable = "Create Table dbo.Blah (BlahId int identity (1, 1) Constraint PK_Blah Primary Key, Document varbinary(max));"


Invoke-Sqlcmd -ServerInstance IT02 -Database Biosystem -Query $rowcount | Where-Object sysadmin -eq 1 | Select-Object -Property loginname | ft
Invoke-Sqlcmd -ServerInstance IT02 -Database Biosystem -Query $rowcount | Where-Object host_name -eq "it02" | ft

Invoke-Sqlcmd -ServerInstance IT02 -Database YourDB -Query $createTable

#Add row
Invoke-Sqlcmd -ServerInstance IT02 -Database YourDB -Query "INSERT INTO Blah (Document) VALUES (999);"

Invoke-Sqlcmd -ServerInstance IT02 -Database YourDB -Query "select * from dbo.Blah"


#Delete row
Invoke-Sqlcmd -ServerInstance IT02 -Database YourDB -Query "DELETE FROM Blah WHERE BlahId = 2;"

#Delete all rows
Invoke-Sqlcmd -ServerInstance IT02 -Database YourDB -Query "DELETE FROM Blah;"





$connString = "Data Source=IT02;Database=Biosystem;User ID=sa;Password=Butcher1985"

    #Create a SQL connection object
    $conn = New-Object System.Data.SqlClient.SqlConnection $connString
    $conn.Open()
    $sqlQuery = "select * from dbo.BS_USER;"
    $command = New-Object System.Data.SqlClient.SqlCommand($sqlQuery, $conn)
    $reader = $command.ExecuteReader()
    $table = $reader.GetSchemaTable()
    $sepatartor = ";"
    $csv="c:\tmp\test.csv"
    $encode = "UTF8"
    $sw = New-Object System.IO.StreamWriter($csv, $false, [Text.Encoding]::UTF8)
    $columns = $table.ColumnName -join ';'
    $sw.WriteLine($columns)
    
    while ($reader.Read()) {
    $row=""
    $cell=""
        for ($i = 0; $i -lt $reader.FieldCount; $i++) {
            $cell=$reader.GetValue($i).ToString()
            $cell=$cell.Replace($sepatartor, " ")
            $row+=$cell
            if ($i -lt $reader.FieldCount -1) {
                $row+=$sepatartor
            }

        }
        $row=$row.Replace("`r`n"," ")
        $sw.WriteLine($row)

    }
    

  <#  $tables = @()
while ($reader.Read()) {
    $tables += $reader["test"]
}#>
$sw.Close()

    $conn.Close()

    Import-Module "C:\Users\bs\Documents\PowerShell\FirebirdSql.Data.FirebirdClient.dll"


    $connStringFB = "User ID = sysdba; Password = masterkey;Database=localhost:c:\\db\\baza\\bujalski.fdb; DataSource=localhost;Charset=NONE;"
    $connfb = New-Object FirebirdSql.Data.FirebirdClient.FbConnection $connStringFB
    $connFb.Open()

    $sqlQuery = "select * from kontrah;"
    $command = New-Object FirebirdSql.Data.FirebirdClient.FbCommand($sqlQuery, $connFb)
    $reader = $command.ExecuteReader()
    $table = $reader.GetSchemaTable()
    $sepatartor = ";"
    $csv="c:\tmp\testFB.csv"
    $encode = "UTF8"
    $sw = New-Object System.IO.StreamWriter($csv, $false, [Text.Encoding]::UTF8)
    $columns = $table.ColumnName -join ';'
    $sw.WriteLine($columns)
    
    while ($reader.Read()) {
    $row=""
    $cell=""
        for ($i = 0; $i -lt $reader.FieldCount; $i++) {
            $cell=$reader.GetValue($i).ToString()
            $cell=$cell.Replace($sepatartor, " ")
            $row+=$cell
            if ($i -lt $reader.FieldCount -1) {
                $row+=$sepatartor
            }

        }
        $row=$row.Replace("`r`n"," ")
        $sw.WriteLine($row)

    }
    $sw.Close()

    $connFb.Close()