<#
Name:           Generate-IntuneSettingsReport.ps1
Autor:          José Pablo Cortés 
Description:    Scripts that generates a CSV Report of every setting in Intune, in each of the available policies. If provided with a DeviceID, 
                then the script will generate an additional colum with the status of the setting. 
Status:         WIP. 
Requirements:   
    - Microsoft Graph Beta (tested with 2.7.0 ) Install-Module Microsoft.Graph.Beta

Usage:
    -Just run it. I haven't transitioned gracefuly from C#, so I still write spagetti PS, so its quite linear. 
#>

#Region :
$moduleBeta = Get-InstalledModule Microsoft.Graph.Beta -ErrorAction SilentlyContinue
if($null -eq $moduleBeta) {Write-Error("No Graph Beta module installed. Use Install-Module Microsoft.Graph.Beta");exit 1}
Write-Host("Found Microsoft.Graph.Beta version ($($moduleBeta.Version))")
#TODO: Doublecheck version checking. 
if($moduleBeta.Version -lt "2.7.0"){Write-Warning("Seems like you running an older version than 2.7.0. This might not work")}

#Region Auth
Connect-MgGraph -Scopes ["DeviceManagementConfiguration.Read.All", "DeviceManagementManagedDevices.Read.All"]