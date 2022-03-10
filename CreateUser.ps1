#How to use it:
#Save on any location and execute it calling ./CreateUser.ps1
#Script will ask you for all the information needed and create the user for you.
#At the end will sync with AD O365
#If you run into any issues please check hiring manager username.

#Import modules needed.
Import-Module ActiveDirectory

#Get variables needed for work
$userFirstName = Read-Host -Prompt 'Input First name'
$UserLastName = Read-Host -Prompt 'Input Last name'
$userAccountName = Read-Host -Prompt 'Input user name'
$userTitle = Read-Host -Prompt 'Input user title'
$userPassword = Read-Host -AsSecureString "Input Password"
$userCellNumber = Read-Host -Prompt 'Input user Cell number'
$userOfficeNumber = Read-Host -Prompt 'Input user Office number'
#AD user need to search and return results
$HiringManager = Read-Host -Prompt 'Input user Hiring manager username'
#Get variable for permanent user
$userPermanent = Read-Host -Prompt 'Is this a permanent user? 1 - Yes | 2 - No'

#Create user
New-ADUser -Name ($userFirstName + " " + $UserLastName) -GivenName $userFirstName -Surname $UserLastName -SamAccountName $userAccountName -UserPrincipalName ($userAccountName + '@yourcompany.com') -Path "OU=CompanyUA,OU=CompanyUsers,OU=Users,OU=MyBusiness,DC=mycompany,DC=local" -AccountPassword $userPassword -Enabled $true -Manager $HiringManager -OtherAttributes @{'title'=$userTitle} -DisplayName ($userFirstName + " " + $UserLastName) -EmailAddress ($userAccountName+"@yourcompany.com") -MobilePhone $userCellNumber -OfficePhone $userOfficeNumber -ScriptPath "gpupdate.bat"


#Add user to groups
#Add-ADGroupMember -Identity 'Domain Users' -Members $userAccountName
if(1 -eq $userPermanent){
    #Only add user to the following groups if user is permanent, or not 1099
    Add-ADGroupMember -Identity 'All Users' -Members $userAccountName
    Add-ADGroupMember -Identity 'Company VPN Users' -Members $userAccountName
    Add-ADGroupMember -Identity 'Remote Desktop Users' -Members $userAccountName
    Add-ADGroupMember -Identity 'Windows Company Fax Users' -Members $userAccountName
    Add-ADGroupMember -Identity 'Windows Company Link Users' -Members $userAccountName
    Add-ADGroupMember -Identity 'Windows Company Remote Web Workplace Users' -Members $userAccountName
    Add-ADGroupMember -Identity 'Windows Company SharePoint_MembersGroup' -Members $userAccountName
}

#Fix issue with AD diall in
Set-ADUser $userAccountName -replace @{msnpallowdialin=$true}

#Sync with O365
Start-ADSyncSyncCycle -policytype delta