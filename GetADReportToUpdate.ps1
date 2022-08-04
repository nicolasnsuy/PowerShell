cls
#Flag to show the computers that are offline on the report
$showOfflineComputers = $false

#Region computerList
$computerList = Import-CSV -Path .\Jira.csv -Header Summary

#Remember to change the new of the column computer name to Summary 
$computerList += Import-CSV -Path .\SCCM_List_WA_WIn10.csv -Header Summary

#endregion computerList

#region Code
$computerReport = @()
$computerTotal = 0
$computerOnlineTotal = 0
$pendingComputers = $computerList.Count

#Check every computer on the list for details
foreach ($computer in $computerList.Summary){
    try{
        cls
        Write-Host "Pending computers" ($pendingComputers - $computerTotal) 
        Write-Host "Processing" $computer
        Write-Host "Trying to contact the computer..."
        $isComputerOnline = Test-Connection -BufferSize 32 -Count 1 -ComputerName $computer -Quiet
        Write-Host "Getting computer info frm AD..."
        $operatingSystem = Get-ADComputer -Identity $computer -Properties OperatingSystemVersion | select OperatingSystemVersion
        #comment this line since is not always needed
        $OperatingSystem2 = Get-ADComputer -Identity $computer -Properties OperatingSystem | select OperatingSystem
        $lastLogon = Get-ADComputer -Filter {Name -eq $computer} -Properties * | Sort LastLogon | Select LastLogonDate,@{Name='LastLogon';Expression={[DateTime]::FromFileTime($_.LastLogon)}}
        $computerLocation = Get-ADComputer -Filter {Name -eq $computer} -Properties * | Select CanonicalName
        if($isComputerOnline){
            try{
                #Get information from user
                Write-Host "Getting user loged in..."
                $userInformation = Get-CimInstance Win32_ComputerSystem -ComputerName $computer | Select-Object -ExpandProperty UserName 
                if($userInformation -eq ""){
                    $userInformation = "Not available"
                }
            }catch{
                $userInformation = "Error: Possible DNS"
            }
            try{
                #Validate that computer doesn't have an old dns record
                Write-Host "Validating DNS name..."
                $ipAddress = Test-Connection -BufferSize 32 -Count 1 -ComputerName $computer | Select IPV4Address
                $realFullHostname = [System.Net.Dns]::GetHostByAddress($ipAddress.IPV4Address).Hostname
                $realHostname = ([Regex]::Matches($realFullHostname, "([A-Z-0-9])\w+").value)

                if($computer -ne $realHostname.Trim()){
                    $userInformation = "DNS reported: " + $realHostname
                    #Under development, the idea is to show hostname + {W} in case the computer available is on the list of computers to work
                    if($computerList.Summary -contains $realHostname){
                        $userInformation += "{W}"
                    }
                }
            }catch{
            }
        }else{
            $userInformation = "Not available"
        }

            Write-Host "Exporting info..."
            $computerReportItem = New-Object PSObject
            $computerReportItem | Add-Member -type NoteProperty -Name Computer -Value $computer
            $computerReportItem | Add-Member -type NoteProperty -Name Online -Value $isComputerOnline
            $computerReportItem | Add-Member -type NoteProperty -Name OS -Value ([Regex]::Matches($operatingSystem.OperatingSystemVersion, "([0-9]{2})\d+").value) 
            $osNumber = ([Regex]::Matches($operatingSystem.OperatingSystemVersion, "([0-9]{2})\d+").value) 
            if($osNumber -eq 19044){
                $computerReportItem | Add-Member -type NoteProperty -Name NeedUpd -Value "NO"
            }else{
                $computerReportItem | Add-Member -type NoteProperty -Name NeedUpd -Value "YES"
            } 
            $computerReportItem | Add-Member -type NoteProperty -Name UserInfo -Value $userInformation
            #comment this line since is not always needed
            $computerReportItem | Add-Member -type NoteProperty -Name OperatingSystemVersion -Value $OperatingSystem2.OperatingSystem
            #Evaluate last logon information to display:
            if($lastLogon.LastLogon -gt $lastLogon.LastLogonDate){
                $computerReportItem | Add-Member -type NoteProperty -Name LastLogon -Value $lastLogon.LastLogon
            }else{
                $computerReportItem | Add-Member -type NoteProperty -Name LastLogon -Value $lastLogon.LastLogonDate
            }
            
            $computerReportItem | Add-Member -type NoteProperty -Name CanonicalName -Value $computerLocation.CanonicalName

            if($showOfflineComputers){
                $computerReport += $computerReportItem
            }else
            {
                if($isComputerOnline){
                    $computerReport += $computerReportItem
                    $computerOnlineTotal +=1
                } 
            }
        
            
    }catch {}
    $computerTotal += 1
}

#Clear screen
cls
#Generate report to print and export
$computerReport | Format-Table 
#Export report
#$computerReport | Select-Object Computer, Online, OS, NeedUpd, UserInfo, LastLogon, CanonicalName | Export-Csv -Path .\ReportAll.csv -NoTypeInformation
$computerReport | Select-Object Computer, Online, OS, NeedUpd, UserInfo, LastLogon, CanonicalName, OperatingSystemVersion | Export-Csv -Path .\ReportAll.csv -NoTypeInformation 
#Get information to know how many computers we have left
Write-Host "Total computers:"$computerTotal -ForegroundColor Red
Write-Host "Active computers: "$computerOnlineTotal -ForegroundColor Green
Write-Host "ReportAll" -ForegroundColor DarkYellow
$ActualDAte = Get-Date
Write-Host "Report finished at:" $ActualDAte
#endregion Code



#Use the LastLogon property to get an accurate last logon date time. Get-ADComputer has lastlogondate property as well but it’s not accurate and updated within 14 days.

