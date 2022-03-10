#Config Variables
$SiteURL = "https://yourcompany.sharepoint.com/sites/Team"
$FileRelativeURL = "/sites/Team/Folder Choosen/Test File.docx"
$DownloadPath = "E:\Folder"
 
#Get Credentials to connect
$Cred = Get-Credential
 
Try {
    #Connect to PNP Online
    Connect-PnPOnline -Url $SiteURL -Credentials $Cred
     
    #powershell download file from sharepoint online
    Get-PnPFile -Url $FileRelativeURL -Path $DownloadPath -AsFile
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}
