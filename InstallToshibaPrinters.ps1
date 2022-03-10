#Printers
try {
   $Url = "http://business.toshiba.com/downloads/KB/f1Ulds/18128/eb4-ebn-Uni-3264bit-7212483517.zip"
   New-Item -ItemType directory -Path C:\Support\Toshiba5015ac
   $DownloadZipFile = "C:\Support\Toshiba5015ac\" + $(Split-Path -Path $Url -Leaf)
   $ExtractPath = "C:\Support\Toshiba5015ac\"
   Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile
   $ExtractShell = New-Object -ComObject Shell.Application
   $ExtractFiles = $ExtractShell.Namespace($DownloadZipFile).Items()
   $ExtractShell.NameSpace($ExtractPath).CopyHere($ExtractFiles)

   pnputil.exe /a "C:\Support\Toshiba5015ac\Driver\64bit\eSf6u.inf"
   Add-PrinterDriver -Name "TOSHIBA Universal Printer 2"
   Add-PrinterPort -Name "Ports Toshiba C-Suite" -PrinterHostAddress "xxx.xxx.xxx.xxx"
   Add-Printer -DriverName "TOSHIBA Universal Printer 2" -Name "COPY CENTER  1" -PortName "Ports Toshiba COPY CENTER 1"
   Add-PrinterPort -Name "Ports Toshiba COPY CENTER" -PrinterHostAddress "xxx.xxx.xxx.xxx"
   Add-Printer -DriverName "TOSHIBA Universal Printer 2" -Name "COPY CENTER 2" -PortName "Ports Toshiba COPY CENTER 2"
}
catch{
   $ErrorMessage = $_.Exception.Message
   $FailedItem = $_.Exception.ItemName
   $ErrorMessage | out-file c:\Support\Script.log -append
   $FailedItem | out-file c:\Support\Script.log -append
}