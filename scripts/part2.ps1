#Constant Variables
$Office365AdminUsername = 'admin@stringbase.in'
$Office365AdminPassword = 'Seclore@123'
$SharedMailboxList = "./output/sharedmailboxlist.json"
$SharedMailboxListFullAccessRights = "./output/sharedmailboxpermissionlist.json"
$SharedMailboxListSendAsRights = "./output/sharedmailboxsendasrightslist.json"

#Main
Function Main
{

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