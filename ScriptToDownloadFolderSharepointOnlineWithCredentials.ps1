#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
  
Function Download-SPOFolder()
{
    param
    (
        [Parameter(Mandatory=$true)] [string] $SiteURL,
        [Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.Folder] $SourceFolder,
        [Parameter(Mandatory=$true)] [string] $TargetFolder
    )
    Try {
          
        #Create Local Folder, if it doesn't exist
        $FolderName = ($SourceFolder.ServerRelativeURL) -replace "/","\"
        $LocalFolder = $TargetFolder + $FolderName
        If (!(Test-Path -Path $LocalFolder)) {
                New-Item -ItemType Directory -Path $LocalFolder | Out-Null
        }
        $FolderDelete = $LocalFolder + "*.*"
        Remove-Item $FolderDelete
          
        #Get all Files from the folder
        $FilesColl = $SourceFolder.Files
        $Ctx.Load($FilesColl)
        $Ctx.ExecuteQuery()
  
        #Iterate through each file and download
        Foreach($File in $FilesColl)
        {
            $TargetFile = $LocalFolder+"\"+$File.Name
            #Download the file
            $FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Ctx,$File.ServerRelativeURL)
            $WriteStream = [System.IO.File]::Open($TargetFile,[System.IO.FileMode]::Create)
            $FileInfo.Stream.CopyTo($WriteStream)
            $WriteStream.Close()
            write-host -f Green "Downloaded File:"$TargetFile
        }
          
        #Process Sub Folders
        $SubFolders = $SourceFolder.Folders
        $Ctx.Load($SubFolders)
        $Ctx.ExecuteQuery()
        Foreach($Folder in $SubFolders)
        {
            If($Folder.Name -ne "Forms")
            {
                #Call the function recursively
                Download-SPOFolder -SiteURL $SiteURL -SourceFolder $Folder -TargetFolder $TargetFolder
            }
        }
     }
    Catch {
        write-host -f Red "Error Downloading Folder!" $_.Exception.Message
    }
}

#Config Variables
$SiteURL = "https://yourcompany.sharepoint.com/sites/HRTeam"
$FileRelativeURL = "/sites/Team/Folder"
$DownloadPath = "E:\Folder"

#Get Credentials to connect
$User = "you@yourcompany.com"
$Userpassword = Get-Content C:\users\tsadmin\desktop\Secureuserpassword.txt | ConvertTo-SecureString
$Auth = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist ($User, $UserPassword)
$Cred = Get-Credential $Auth
 
Try {
    #Connect to PNP Online
    Connect-PnPOnline -Url $SiteURL -Credentials $Cred
     
    #powershell download file from sharepoint online
    #Get-PnPFile -Url $FileRelativeURL -Path $DownloadPath -AsFile
    
    #Get the Web
    $Web = $Ctx.Web
 
    #Get the Folder
    $SourceFolder = $Web.GetFolderByServerRelativeUrl($FileRelativeUrl)


    Download-SPOFolder -SiteURL $SiteURL -SourceFolder $SourceFolder -TargetFolder $DownloadPath
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}
