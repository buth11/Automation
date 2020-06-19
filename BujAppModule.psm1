
function Export-MSSQL {
    param (
        [string] $sqlQuery,
        [string] $csv
    )
    

$connString = "Data Source=IT02;Database=Biosystem;User ID=sa;Password=Butcher1985"

#Create a SQL connection object
$conn = New-Object System.Data.SqlClient.SqlConnection $connString
$conn.Open()
#$sqlQuery = "select * from dbo.BS_USER;"
$command = New-Object System.Data.SqlClient.SqlCommand($sqlQuery, $conn)
$reader = $command.ExecuteReader()
$table = $reader.GetSchemaTable()
$sepatartor = ";"
#$csv="c:\tmp\test.csv"
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
}


function Export-FBSQL {
    param (
        [string] $sqlQuery,
        [string] $csv
    )
#Import-Module (Join-Path $PSScriptRoot $_.FileName) -Verbose -Global
#Import-Module "$env:USERPROFILE\Documents\PowerShell\FirebirdSql.Data.FirebirdClient.dll" -Verbose -Global


$connStringFB = "User ID = sysdba; Password = masterkey;Database=localhost:c:\\db\\baza\\bujalski.fdb; DataSource=localhost;Charset=NONE;"
$connfb = New-Object FirebirdSql.Data.FirebirdClient.FbConnection $connStringFB
$connFb.Open()

#$sqlQuery = "select * from kontrah;"
$command = New-Object FirebirdSql.Data.FirebirdClient.FbCommand($sqlQuery, $connFb)
$reader = $command.ExecuteReader()
$table = $reader.GetSchemaTable()
$sepatartor = ";"
#$csv="c:\tmp\testFB.csv"
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

}