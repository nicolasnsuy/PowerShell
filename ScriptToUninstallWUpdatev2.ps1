if(Get-HotFix -Id KB5009543){
    #Update is installed, searching for package name to delete it
    Get-WindowsPackage -Online | ?{$_.ReleaseType -like "*Update*"} | `
    ForEach-Object {Get-WindowsPackage -Online -PackageName $_.PackageName} | `
    Where-Object {$_.Description -like "*KB5009543*"} | Remove-WindowsPackage -Online -NoRestart
    #Update uninstalled successfully
    #Hidding update to avoid re installation
    try{
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Install-PackageProvider -Name NuGet -Force
        Install-Module PSWindowsUpdate -Force 
        Import-Module PSWindowsUpdate 
        Hide-WindowsUpdate -KBArticleID KB5009543
    }catch{
        echo 'Error while trying to hide windows update KB:5009543'
    }
    
    msg * "We just updated your computer. A reboot is required to finish the process. Please save your work and do it ASAP."
    
}
#No else, if is not installed - no action is required