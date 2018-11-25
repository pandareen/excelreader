Param ([string]$Username, [string]$Password, [string]$ConnectionUrl)

Get-PSSession | Remove-PSSession
$SecureOffice365Password = ConvertTo-SecureString -AsPlainText $Password -Force
$Office365Credentials = New-Object System.Management.Automation.PSCredential $Username, $SecureOffice365Password
#$ConnectionUrl  =   https://ps.outlook.com/powershell
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUrl -Credential $Office365credentials -Authentication Basic -AllowRedirection
Import-PSSession $Session