## Active Directory Domain Controller Replication Status For Solarwinds##

#$domaincontroller = Read-Host 'What is your Domain Controller?'
#You can hardcode using '' or this example will take the first argument of the script
$domaincontroller = $args[0]

## Define Objects ##
$report = New-Object PSObject -Property @{
ReplicationPartners = $null
LastReplication = $null
FailureCount = $null
FailureType = $null
FirstFailure = $null

}

try{
    ## Replication Partners ##
    $report.ReplicationPartners = (Get-ADReplicationPartnerMetadata -Target $domaincontroller).Partner
    $report.LastReplication = (Get-ADReplicationPartnerMetadata -Target $domaincontroller).LastReplicationSuccess

    ## Replication Failures ##
    $report.FailureCount  = (Get-ADReplicationFailure -Target $domaincontroller).FailureCount
    $report.FailureType = (Get-ADReplicationFailure -Target $domaincontroller).FailureType
    $report.FirstFailure = (Get-ADReplicationFailure -Target $domaincontroller).FirstFailureTime

    ## Format Output ##
    #$report | select ReplicationPartners,LastReplication,FirstFailure,FailureCount,FailureType | Out-GridView

    #Exit codes:
    # Exit 0 = No error
    # Exit > 0 = Error, not message is shown
    # Exit > 1000 = Error, Msg will show, use Write-Host
    #https://documentation.n-able.com/remote-management/userguide/Content/script_guide_return.htm
    if($report.FailureCount > 0){
        #
        Write-Host "Replication cannot be determined"
        Exit 1001
    }else{
        #
        Write-host "Replication successfull, Last sync at:" $report.LastReplication
        Exit 0
    }
}catch [Exception]{
    Write-Host "Replication cannot be determined"
    Exit 1001
}