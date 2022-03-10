#Script to deploy machines:

#Agent
#Install it manually so you can use the script.

#Office
#not available yet

#Zoom extension
#Pending to know how to install it.

#Box tools
#Pending to know how to install it.

#Actual installations: VPN, Chrome, Adobe reader, JumpCloud, Printers, Zoom, Box, 

#Pre requisites
New-Item -ItemType directory -Path C:\Support\Setup

#Settings to avoid going sleep mode conected to charger
Powercfg /Change monitor-timeout-ac 60
Powercfg /Change monitor-timeout-dc 15
Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 30

#VPN
#see VPN Script, you can copy and paste the contents here

#Chrome
try{
$LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe"; (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)
}catch{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   $ErrorMessage | out-file c:\Support\ScriptDeploy.log -append
   $FailedItem | out-file c:\Support\ScriptDeploy.log -append
}

#Adobe reader
try{
$Url = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2100520058/AcroRdrDC2100520058_en_US.exe"
#New-Item -ItemType directory -Path C:\Support\Setup
$DownloadZipFile = "C:\Support\Setup\" + $(Split-Path -Path $Url -Leaf)
Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile
#crear script que descarque archivo desde https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2100520058/AcroRdrDC2100520058_en_US.exe
Start-Process -FilePath "C:\Support\Setup\AcroRdrDC2100520058_en_US.exe" -ArgumentList "/sAll /rs /rps /msi /norestart /quiet EULA_ACCEPT=YES" -WorkingDirectory "C:\" -Wait
}catch{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   $ErrorMessage | out-file c:\Support\ScriptDeploy.log -append
   $FailedItem | out-file c:\Support\ScriptDeploy.log -append
}

#JumpCloud
try{
   cd $env:temp | Invoke-Expression; Invoke-RestMethod -Method Get -URI https://raw.githubusercontent.com/TheJumpCloud/support/master/scripts/windows/InstallWindowsAgent.ps1 -OutFile InstallWindowsAgent.ps1 | Invoke-Expression; ./InstallWindowsAgent.ps1 -JumpCloudConnectKey "YourAPIKey"
}catch{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   $ErrorMessage | out-file c:\Support\ScriptDeploy.log -append
   $FailedItem | out-file c:\Support\ScriptDeploy.log -append
}

#Printers
#Check file for printer installations, you can copy and paste the contents here

#Zoom
try{
   $Url = "https://www.zoom.us/client/latest/ZoomInstallerFull.msi"
   #New-Item -ItemType directory -Path C:\Support\Setup
   $DownloadZipFile = "C:\Support\Setup\" + $(Split-Path -Path $Url -Leaf)
   Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile
   cd C:\Support\Setup
   msiexec /i ZoomInstallerFull.msi ZSilentStart=true ZSSOHost="yourcompany.zoom.us" ZConfig=nofacebook=1 /quiet /qn /norestart /log zoomInstall.log
}catch{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   $ErrorMessage | out-file c:\Support\Script.log -append
   $FailedItem | out-file c:\Support\Script.log -append
}

#Box
try{
   $Url = "https://e3.boxcdn.net/box-installers/desktop/releases/win/Box-x64.msi"
   #New-Item -ItemType directory -Path C:\Support\Setup
   $DownloadZipFile = "C:\Support\Setup\" + $(Split-Path -Path $Url -Leaf)
   Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile
   cd C:\Support\Setup\
   MsiExec.exe /i Box-x64.msi /qn
}catch{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   $ErrorMessage | out-file c:\Support\Script.log -append
   $FailedItem | out-file c:\Support\Script.log -append
}


#Teams
try{
   $Url ="https://statics.teams.cdn.office.net/production-windows-x64/1.4.00.19572/Teams_windows_x64.msi"
   #$Url = "https://aka.ms/teams64bitmsi"
   #New-Item -ItemType directory -Path C:\Support\Setup
   $DownloadZipFile = "C:\Support\Setup\" + $(Split-Path -Path $Url -Leaf)
   Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile
   cd C:\Support\Setup\
   MsiExec.exe /i Teams_windows_x64.msi ALLUSERS=1 /qn /norestart
   #Need reboot to work but is install on every user
}catch{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   $ErrorMessage | out-file c:\Support\Script.log -append
   $FailedItem | out-file c:\Support\Script.log -append
}

#Vonage
try{
   $Url ="https://s3.amazonaws.com/vbcdesktop.vonage.com/prod/win/VonageBusinessSetupPerMachine.msi"
   #New-Item -ItemType directory -Path C:\Support\Setup
   $DownloadZipFile = "C:\Support\Setup\" + $(Split-Path -Path $Url -Leaf)
   Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile
   cd C:\Support\Setup\
   MsiExec.exe /i "C:\Support\Setup\VonageBusinessSetupPerMachine.msi" /qn /norestart
}catch{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   $ErrorMessage | out-file c:\Support\Script.log -append
   $FailedItem | out-file c:\Support\Script.log -append
}

#Uninstall Pre Installed Apps, not working for some reason
try{
   #Get-AppxPackage -AllUsers | Select Name, PackageFullName
   Get-AppxPackage -Name "SpotifyAB.SpotifyMusic" -AllUsers | Remove-AppxPackage -AllUSers
   Get-AppxPackage -Name "5A894077.McAfeeSecurity" -AllUsers | Remove-AppxPackage -AllUSers
   Get-AppxPackage -Name "C27EB4BA.DropboxOEM" -AllUsers | Remove-AppxPackage -AllUSers
   Get-AppxPackage -Name "DellInc.PartnerPromo" -AllUsers | Remove-AppxPackage -AllUSers
   Get-AppxPackage -Name "5A894077.McAfeeSecurity" -AllUsers | Remove-AppxPackage -AllUSers
}catch{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   $ErrorMessage | out-file c:\Support\Script.log -append
   $FailedItem | out-file c:\Support\Script.log -append
}



#Disable News & Interests
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d 0 /f

Restart-Computer -Force

#---------------------------------------------------------------------------------------------------------
#Experimental
#Use manually and take your time to use
Install-Module PSWindowsUpdate -Force
#Wait 3 secs & Confirm execution
#y
Get-WindowsUpdate
#Wait until you see available packages
Install-WindowsUpdate -Force
#Wait 3 secs & confirm installation of all packages
#a
#Confirmation is needed to reboot y or n
#y

#Add office and microsoft services to updates
Add-WUServiceManager -MicrosoftUpdate
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot


Restart-Computer -Force