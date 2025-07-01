# Connect to Microsoft Graph interactively



function Get-DevicesWithScopeTag {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$scopeTagName <#,

        [Parameter(Mandatory = $false)]
        [string]$Param2
        #>
    )

    Install-Module Microsoft.Graph -Scope CurrentUser
    Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All", "DeviceManagementRBAC.Read.All"

    # Define the scope tag name
    $scopeTagName = $scopeTagName

    # Get the scope tag ID
    $scopeTag = Get-MgDeviceManagementRoleScopeTag | Where-Object { $_.DisplayName -eq $scopeTagName }

    if (-not $scopeTag) {
        Write-Error "Scope tag '$scopeTagName' not found."
        return
    }

    $scopeTagId = $scopeTag.Id

    # Get all managed devices and filter locally by scope tag
    $devices = Get-MgDeviceManagementManagedDevice -All | Where-Object {
        $_.RoleScopeTagIds -contains $scopeTagId
    }

    # Display results
    $devices | Select-Object Id, DeviceName, OperatingSystem, ComplianceState | Format-Table -AutoSize
}