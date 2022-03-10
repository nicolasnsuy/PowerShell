#To execute this script call it as ./DisableUSer.ps1 username


param([string]$UserToDisable)
#Disable user
Disable-ADAccount -Identity $UserToDisable
 
#Move user to disabled users folder
Get-ADUser $UserToDisable| Move-ADObject -TargetPath 'OU=Disabled Accounts,OU=Non Billable Accounts,DC=mycompany,DC=local'
 
#Hide users from address book that exist on disabled accounts OU
$users = get-adobject -filter {objectclass -eq $UserToDisable} -searchbase "OU=Disabled Accounts,OU=Non Billable Accounts,DC=mycompany,DC=local"
 
foreach ($User in $users)
{
    Set-ADObject $user -replace @{msExchHideFromAddressLists=$true}
    Set-ADObject $user -clear ShowinAddressBook
}
 
#Remove all groups exept Domain users, change parameter false to true if you wish to be asked for every group
Get-ADUser -Identity $UserToDisable -Properties MemberOf | ForEach-Object {
  $_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false
}
 
#Sync changes to O365
Start-ADSyncSyncCycle -policytype delta
