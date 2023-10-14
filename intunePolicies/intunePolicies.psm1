<#==================================================================================
MIT License

Copyright (c) 2023 José Pablo Cortés

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
================================================================================== 
.Synopsis
Loads and list All the intune Policies. 

Usage: 
Install Microsoft Graph Beta by: 
    Install-Module Microsoft.Graph.Beta -Scope CurrentUser 
With Powershell, cd to current directory and Import-Module this folder

#>
function get-IntunePolicies {
    param (
        
    )
    Write-Host("Function: get-IntunePolicies")
    Connect-MgGraph -Scopes "DeviceManagementApps.ReadWrite.All" -NoWelcome
    $policies = Get-MgBetaDeviceManagementConfigurationPolicy
    Write-Host("Found ($($policies.Count)) Policies. Expanding Settings") -ForegroundColor Yellow
    foreach($pol in $policies){
        
        Write-Host("Policy: $($pol.Name)")
    }
    
    
}
Export-ModuleMember -Function get-IntunePolicies