Param ([long]$StartTime, [long]$EndTime, [string]$OutputFile)

$EpochStart = Get-Date -Day 1 -Month 1 -Year 1970 -Hour 0 -Minute 0 -Millisecond 0 -Second 0

$Lower = Get-Date $EpochStart.AddMilliseconds($StartTime)

$Upper = Get-Date $EpochStart.AddMilliseconds($EndTime)



function Get-Objects-From-Array($Array, [System.Collections.Generic.HashSet[String]]$set)
{
    foreach ($item in $Array)
    {
        $set.Add($item.sid.tostring())
    }
    return;
}


function Get-UserOrGroup([string]$InputString, [System.Collections.Generic.HashSet[String]]$set, [string]$ExcludeDomain)
{
    if ([string]::IsNullOrWhiteSpace($InputString) -eq $true -or $InputString -like '1-S-*' -or $InputString -like '*\*')
    {
        return;
    }


    $targetObject = $null
    if ($InputString -like '*@*' -and (([string]::IsNullOrWhiteSpace($ExcludeDomain) -eq $true) -or ($InputString.EndsWith($ExcludeDomain) -eq $false)))
    {
        $targetObject = Get-User -Identity $InputString -Filter { WindowsEmailAddress -eq $InputString.tostring() } -ErrorAction SilentlyContinue
        if ($targetObject -ne $null)
        {
            Get-Objects-From-Array $targetObject $set
            return;
        }
        $targetObject = Get-Group -Identity $InputString -Filter { WindowsEmailAddress -eq $InputString.tostring() } -ErrorAction SilentlyContinue
        if ($targetObject -ne $null)
        {
            Get-Objects-From-Array $targetObject $set
            return;
        }

    }

    $targetObject = Get-Group -Identity $InputString -Filter { Name -eq $InputString.tostring() } -ErrorAction SilentlyContinue
    if ($targetObject -ne $null -and (([string]::IsNullOrWhiteSpace($ExcludeDomain) -eq $true) -or ($targetObject.WindowsEmailAddress.EndsWith($ExcludeDomain) -eq $false)))
    {
        Get-Objects-From-Array $targetObject $set
        return;
    }

}


function Get-AliasList([string[]]$Aliases, [string]$ExcludeDomain, [System.Collections.Generic.HashSet[String]]$AliasSet, [ref][string]$primaryEmail)
{
    Foreach ($Alias in $Aliases)
    {
        if ($Alias -like 'smtp*' -and (([string]::IsNullOrWhiteSpace($ExcludeDomain) -eq $true) -or ($Alias.EndsWith($ExcludeDomain) -eq $false)))
        {
            $position = $Alias.IndexOf(':')
            if ($position -eq -1)
            {
                continue
            }
            if ($Alias -clike 'SMTP*')
            {
                $primaryEmail.Value = $Alias.Substring($position + 1)
            }
            else
            {
                $AliasSet.Add($Alias.Substring($position + 1))
            }

        }
    }
}


#$shared_mailboxes = Get-Mailbox | where { $_.recipientTypeDetails -eq 'sharedmailbox' }
$shared_mailboxes = Get-Mailbox -Identity "testing"


$FinalList = New-Object System.Collections.ArrayList
Foreach ($sharedmailbox in $shared_mailboxes)
{
    $MembersSet = New-Object System.Collections.Generic.HashSet[String]
    $grantsendonbehalfto = $sharedmailbox | Select -ExpandProperty GrantSendOnbehalfto
    forEach ($gsobto in $grantsendonbehalfto)
    {
        Get-UserOrGroup $gsobto.tostring() $MembersSet $ExcludeDomain
    }
    $primaryEmail = ""
    $Aliases = $sharedmailbox | Select -ExpandProperty EmailAddresses
    $AliasSet = New-Object System.Collections.Generic.HashSet[String]
    Get-AliasList $Aliases $ExcludeDomain $AliasSet ([ref]$primaryEmail)

    $full_access_permissions = Get-MailboxPermission -Identity $sharedmailbox.ExternalDirectoryObjectId | ? { $_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false -and $_.AccessRights -like '*FullAccess*' }
    forEach ($fap in $full_access_permissions)
    {
        Get-UserOrGroup $fap.User $MembersSet $ExcludeDomain
    }

    $recipient_permission_list = Get-RecipientPermission -Identity $sharedmailbox.ExternalDirectoryObjectId | ? { $_.Trustee -ne "NT AUTHORITY\SELF" -and $_.AccessRights -like '*SendAs*' }
    forEach ($rpl in $recipient_permission_list)
    {
        Get-UserOrGroup $rpl.Trustee $MembersSet $ExcludeDomain
    }

    $ourObject = New-Object -TypeName PSObject
    $ourObject | Add-Member -MemberType NoteProperty -Name 'uniqueId' -Value $sharedmailbox.ExternalDirectoryObjectId
    $ourObject | Add-Member -MemberType NoteProperty -Name 'displayName' -Value $sharedmailbox.DisplayName
    $ourObject | Add-Member -MemberType NoteProperty -Name 'primaryEmail' -Value $primaryEmail
    $ourObject | Add-Member -MemberType NoteProperty -Name 'members' -Value $MembersSet
    $ourObject | Add-Member -MemberType NoteProperty -Name 'aliases' -Value $AliasSet
    $FinalList.Add($ourObject)
}

$FinalList | ConvertTo-Json -Depth 4 > $OutputFile