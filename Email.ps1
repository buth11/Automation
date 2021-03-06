#Send email
Import-Module -Name (
    Get-ChildItem "($env:ProgramFiles)\Microsoft\Exchange\Web Services" "Microsoft.Exchange.WebServices.dll" -Recurse |
    Select-Object -ExpandProperty FullName -First 1)

    #Start ssl
    $Provider=New-Object Microsoft.CSharp.CSharpCodeProvider
    $Compiler=$Provider.CreateCompiler()
    $Params=New-Object System.CodeDom.Compiler.CompilerParameters
    $Params.GenerateExecutable=$false
    $Params.GenerateInMemory=$true
    $Params.IncludeDebugInformation=$false
    $Params.ReferencedAssemblies.Add("System.DLL") | Out-Null

    $TASource=@'
    namespace Local.ToolkitExtensions.Net.CertificatePolicy{
        public class TrustAll : System.Net.ICertificatePolicy{
            public TrustAll() {
            }
            public bool CheckValidationResult(System.Net.ServicePoint sp,
            System.Security.Cryptography.X509Certificates.X509Certificate cert,
            System.Net.WebRequest req, int problem) {
            return true;
            }
        }
    }
'@
$TAResults = $Provider.CompileAssemblyFromSource($Params,$TASource)
$TAAssembly = $TAResults.CompiledAssembly

$TrustAll = $TAAssembly.CreateInstance("Local.ToolkitExtensions.Net.CertificatePolicy.TrustAll")
[System.Net.ServicePointManager]::CertificatePolicy=$TrustAll
#End of SSL

#Login to Exchange
$exchangeService=New-Object Microsoft.Exchange.WebServices.Data.ExchangeService("Exchange2013")
$exchangeService.Credentials = [System.Net.CredentialCache]::DefaultCredentials
$exchangeService.AutodiscoverUrl("user1@corp.contoso.com")

#Subscribe to new email
$inboxId = New-Object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::InboxId)
$inboxIdArray = New-Object Microsoft.Exchange.WebServices.Data.FolderId[] 1
$inboxIdArray[0] = $inboxId
$pullSubscription = $exchangeService.SubscribeToPullNotifications($inboxIdArray, 60, $null, [Microsoft.Exchange.WebServices.Data.EventType]::NewMail)

Write-Verbose "Triggering boss's email for testing."
Start-SimulateBackupEmail

#Polling loop
try {
    do {
        $events = $pullSubscription.GetEvents();
        if ($events.AllEvents.Count -eq 0) {
         #Don't hammer the servers
         Start-Sleep 1   
        }else {
            foreach ($event in $events.AllEvents){
                #Fully retrive the email
                $emailItem = [Microsoft.Exchange.WebServices.Data.Item]::Bind($exchangeService, $event.ItemId)
                $emailItem.Load()
                Write-Verbose "$($event.EventType) from $($emailItem.Sender.Name) ($($emailItem.Sender.Address))"

                if ($emailItem.Sender.Address -eq "bossyboss@corp.contoso.com" -and $emailItem.Subject -like "*boss") {
                    Write-Verbose "Help request recived"

                    #The work needs to be done here

                    $replayItem = $emailItem.CreateReplay($true)
                    $replayItem.BodyPrefix = "Okay, that's done."
                    $replayItem.SendAndSaveCopy()
                    $emailItem.Delete("MoveToDeletedItems")

                    Write-Verbose "Help request processed."
                } else{
                    Write-Verbose "Ignored."
                }
            }
        }
    } while ($true) 
    }catch {
    throw
    }finally{
        $pullSubscription.Unsubscribe()
    
}