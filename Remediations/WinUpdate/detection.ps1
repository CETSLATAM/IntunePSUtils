# Description: This script checks the Windows OS version and the last update date.
# It ensures that the OS is at least Windows 10 version 19045 or Windows 11 version 22631.  
# If the OS version is lower, it outputs the current version and exits with code 1.
# If the last update was more than 40 days ago, it outputs a message and exits with code 1.
# If the last update was within 40 days, it outputs a message and exits with code 0.

#taken from https://www.reddit.com/r/Intune/comments/17ls8i2/windows_update_remediation/
$CurrentWin10 = [Version]"10.0.19045"
$CurrentWin11 = [Version]"10.0.22631"

$GetOS = Get-ComputerInfo -property OsVersion
$OSversion = [Version]$GetOS.OsVersion

if  ($OSversion -match [Version]"10.0.1")
    {
    if  ($OSversion -lt $CurrentWin10)
        {
        Write-Output "OS version currently on $OSversion"
        exit 1
        }
    }

if  ($OSversion -match [Version]"10.0.2")
    {
    if  ($OSversion -lt $CurrentWin11)
        {
        Write-Output "OS version currently on $OSversion"
        exit 1
        }
    }

$lastupdate = Get-HotFix | Sort-Object -Property @{Expression = { if ($_.InstalledOn) { [datetime]::Parse($_.InstalledOn) } else { [datetime]::MinValue } }} | Select-Object -Last 1 -ExpandProperty InstalledOn

$Date = Get-Date

$diff = New-TimeSpan -Start $lastupdate -end $Date
$days = $diff.Days
if  ($days -ge 40)
    {
     Write-Output "Troubleshooting Updates - Last update was $days days ago"
     exit 1
    }
else{
 Write-Output "Windows Updates ran $days days ago"
    exit 0
    }