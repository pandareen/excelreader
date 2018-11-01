#Constant Variables
$Office365AdminUsername = 'admin@stringbase.in'
$Office365AdminPassword = 'Seclore@123'
$SharedMailboxList = "./output/sharedmailboxlist.json"
$SharedMailboxListFullAccessRights = "./output/sharedmailboxpermissionlist.json"
$SharedMailboxListSendAsRights = "./output/sharedmailboxsendasrightslist.json"

#Main
Function Main
{
    Write-Host : $blah
    #Remove all existing Powershell sessions
    Get-PSSession | Remove-PSSession


    #Encrypt password for transmission to Office365
    $SecureOffice365Password = ConvertTo-SecureString -AsPlainText $Office365AdminPassword -Force


    #Build credentials object
    $Office365Credentials = New-Object System.Management.Automation.PSCredential $Office365AdminUsername, $SecureOffice365Password
    Write-Host : 'Credentials object created'

    #Create remote Powershell session
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $Office365credentials -Authentication Basic -AllowRedirection
    Write-Host : 'Remote session established'

    #Check for errors
    if ($Session -eq $null)
    {
        Write-Host : 'Invalid creditials'
    }
    else
    {
        Write-Host : 'Login success'
        #Import the session
        Import-PSSession $Session
    }

    exit
}

# Start script
. Main