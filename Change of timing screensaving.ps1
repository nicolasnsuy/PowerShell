#Disable screen lock timing GPO 
Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -name "interactive logon: Machine inactivity limit" -value 0
#Enable Screen lock timing GPO
#Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -name "interactive logon: Machine inactivity limit" -value 900


#Schedule a task to revert it, siply save the last command in a ps1 called RevertPolicy on C:\Support\ Execute it as admin
$Time=New-ScheduledTaskTrigger -At 10.00PM -Once

$Action=New-ScheduledTaskAction -Execute PowerShell.exe -WorkingDirectory C:/Support -Argument “C:\Support\RevertPolicy.ps1 -UserName xxx -Password XX

Register-ScheduledTask -TaskName "Schedule Revert policy lockscreen" -Trigger $Time -Action $Action -RunLevel Highest