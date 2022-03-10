#Download fonts from my server
#Create folder for each font
#Extract font in folders and install it

$Url = "https://itisnotcomplicated.com/fonts/Oxygen.zip"

New-Item -ItemType directory -Path C:\Support\Fonts\Oxygen

$DownloadZipFile = "C:\Support\Fonts\Oxygen\" + $(Split-Path -Path $Url -Leaf)

$ExtractPath = "C:\Support\Fonts\Oxygen\"

Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile

$ExtractShell = New-Object -ComObject Shell.Application 

$ExtractFiles = $ExtractShell.Namespace($DownloadZipFile).Items() 

$ExtractShell.NameSpace($ExtractPath).CopyHere($ExtractFiles) 
Remove-Item 'C:\Support\Fonts\Oxygen\Oxygen.zip'
Remove-Item 'C:\Support\Fonts\Oxygen\OFL.txt'
#Start-Process $ExtractPath

$Url = "https://itisnotcomplicated.com/fonts/Teko.zip"

New-Item -ItemType directory -Path C:\Support\Fonts\Teko

$DownloadZipFile = "C:\Support\Fonts\Teko\" + $(Split-Path -Path $Url -Leaf)

$ExtractPath = "C:\Support\Fonts\Teko\"

Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile

$ExtractShell = New-Object -ComObject Shell.Application 

$ExtractFiles = $ExtractShell.Namespace($DownloadZipFile).Items() 

$ExtractShell.NameSpace($ExtractPath).CopyHere($ExtractFiles) 
Remove-Item 'C:\Support\Fonts\Teko\Teko.zip'
Remove-Item 'C:\Support\Fonts\Teko\OFL.txt'
#Start-Process $ExtractPath