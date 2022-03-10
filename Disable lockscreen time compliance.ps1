#Excecute this command as admin on PowerShell
Set-Itemproperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -name "interactive logon: Machine inactivity limit" -value 0