#Constant Variables
$Office365AdminUsername = 'admin@stringbase.in'
$Office365AdminPassword = 'Seclore@123'
$SharedMailboxList = "./output/sharedmailboxlist.json"
$SharedMailboxListFullAccessRights = "./output/sharedmailboxpermissionlist.json"
$SharedMailboxListSendAsRights = "./output/sharedmailboxsendasrightslist.json"
$SharedMailboxListGrantOnBehalfOf = "./output/sharedmailboxgrantonbehalfoflist.json"

#Main
Function Main
{
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

    $shared_mailboxes = Get-Mailbox | where {$_.recipientTypeDetails -eq 'sharedmailbox' }

    $shared_mailboxes | ConvertTo-Json > $SharedMailboxList

    $shared_mailboxes_permission = $shared_mailboxes | Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false}

    $shared_mailboxes_permission | ConvertTo-Json > $SharedMailboxListFullAccessRights

    $recipient_permission = Get-Mailbox -ResultSize Unlimited | Get-RecipientPermission | ? {$_.Trustee -ne "NT AUTHORITY\SELF"}

    $recipient_permission | ConvertTo-Json > $SharedMailboxListSendAsRights

    $granted_on_behalf = $shared_mailboxes |  ? {$_.GrantSendOnBehalfTo -ne $null} | select Name,Alias,UserPrincipalName,PrimarySmtpAddress,GrantSendOnBehalfTo

    $granted_on_behalf | ConvertTo-Json > $SharedMailboxListGrantOnBehalfOf

    exit
}

# Start script
. Main