Param ([long]$StartTime, [long]$EndTime, [string]$OutputFile)

$EpochStart = Get-Date -Day 1 -Month 1 -Year 1970 -Hour 0 -Minute 0 -Millisecond 0 -Second 0

$Lower = Get-Date $EpochStart.AddMilliseconds($StartTime)

$Upper = Get-Date $EpochStart.AddMilliseconds($EndTime)

Get-Mailbox -SoftDeletedMailbox | where { $_.recipientTypeDetails -eq 'sharedmailbox' -and $_.WhenChangedUTC -gt $Lower -and $_.WhenChangedUTC -lt $Upper } | select @{ N = 'uniqueId'; E = { $_.ExternalDirectoryObjectId } } | ConvertTo-Json > $OutputFile