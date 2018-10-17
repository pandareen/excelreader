#Constant Variables
$Office365AdminUsername = 'admin@stringbase.in'
$Office365AdminPassword = 'Seclore@123'
$SharedMailboxList = "./output/sharedmailboxlist.json"
$SharedMailboxListFullAccessRights = "./output/sharedmailboxpermissionlist.json"
$SharedMailboxListSendAsRights = "./output/sharedmailboxsendasrightslist.json"

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

    $shared_mailboxes | Select ExternalDirectoryObjectId, UserPrincipalName, GrantSendOnBehalfTo | ConvertTo-Json > $SharedMailboxList

    $shared_mailboxes_permission =  Foreach ($smb in $shared_mailboxes) {
        $full_access_permissions = Get-MailboxPermission -Identity $smb.ExternalDirectoryObjectId | ? { $_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false -and $_.AccessRights -eq 'FullAccess' }
        $permission_result = $full_access_permissions  | Select AccessRights, User, @{ Name = "extDirObjId"; Expression = { $smb.ExternalDirectoryObjectId } }
        $permission_result
    }

    $shared_mailboxes_permission | ConvertTo-Json > $SharedMailboxListFullAccessRights

    $recipient_permission =   Foreach ($smb in $shared_mailboxes) {
        $recipient_permission_list = Get-RecipientPermission -Identity $smb.ExternalDirectoryObjectId | ? { $_.Trustee -ne "NT AUTHORITY\SELF" -and $_.AccessRights -eq 'SendAs' }
        $recipient_permission_result = $recipient_permission_list | Select AccessRights, Trustee, @{ Name = "extDirObjId"; Expression = { $smb.ExternalDirectoryObjectId } }
        $recipient_permission_result
    }
    $recipient_permission | ConvertTo-Json > $SharedMailboxListSendAsRights

    exit
}

# Start script
. Main