#=============================================================================================================================
#
# Script Name:     WinUpdate - Nuclear Reset.ps1
# Description:     Nuclear reset of Windows Update settings to allow Windows 11 upgrade.
#                  This script resets Windows Update settings, stops services, deletes cache, resets registry keys,
#                  and triggers a Windows Update scan to enable the Windows 11 upgrade offer.

#
#=============================================================================================================================
<#
MIT License

Copyright (c) 2025 José Pablo Cortés

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


#>

$logPath = "C:\updateLogs"
$logFile = "$logPath\logs.txt"

# Ensure log directory exists
if (!(Test-Path -Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force
}

# Function to log messages
function Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append -Encoding utf8
}

# Detection: Check if Windows 11 upgrade is already installed
$osVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
if ($osVersion -like "*Windows 11*") {
    Log "Windows 11 is already installed. No action required."
    exit 0
}

Log "================================================================"
Log "Starting remediation: Resetting Windows Update settings..."
Log "================================================================"


# Stop update services
$services = "wuauserv","bits","cryptsvc","msiserver"
foreach ($svc in $services) {
    try {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Log "Stopped service: $svc"
    } catch {
        Log "Failed to stop service: $svc"
        Log "================================================================="
        $ErrorMessage = "[$(Get-Date)] ERROR: $($_.Exception.Message)"
        Log "ERROR:"
        Log $ErrorMessage
    }
}

# Remove update cache
try {
    Remove-Item -Path "C:\Windows\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
    Log "Deleted SoftwareDistribution folder"
    
} catch {
    Log "Failed to delete SoftwareDistribution folder"
    Log "================================================================="
    $ErrorMessage = "[$(Get-Date)] ERROR: $($_.Exception.Message)"
    Log "ERROR:"
    Log $ErrorMessage
}

try {
    Remove-Item -Path "C:\Windows\System32\catroot2" -Recurse -Force -ErrorAction SilentlyContinue
    Log "Deleted catroot2 folder"
} catch {

    Log "Failed to delete catroot2 folder"
    Log "================================================================="
    $ErrorMessage = "[$(Get-Date)] ERROR: $($_.Exception.Message)"
    Log "ERROR:"
    Log $ErrorMessage
}

# Reset registry keys
try {
    Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
    Log "Reset WindowsUpdate registry keys"
} catch {
    Log "Failed to reset WindowsUpdate registry keys"
    Log "================================================================="
    $ErrorMessage = "[$(Get-Date)] ERROR: $($_.Exception.Message)"
    Log "ERROR:"
    Log $ErrorMessage
}

# Restart services
foreach ($svc in $services) {
    try {
        Start-Service -Name $svc -ErrorAction SilentlyContinue
        Log "Started service: $svc"
    } catch {
        Log "Failed to start service: $svc"
        Log "================================================================="
        $ErrorMessage = "[$(Get-Date)] ERROR: $($_.Exception.Message)"
        Log "ERROR:"
        Log $ErrorMessage
    }
}

# Enable Windows 11 upgrade offer
try {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "TargetReleaseVersion" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "TargetReleaseVersionInfo" -PropertyType String -Value "Windows 11" -Force | Out-Null
    Log "Enabled Windows 11 upgrade offer via registry"
} catch {
    Log "Failed to enable Windows 11 upgrade offer"
    Log "================================================================="
    $ErrorMessage = "[$(Get-Date)] ERROR: $($_.Exception.Message)"
    Log "ERROR:"
    Log $ErrorMessage
}

# Trigger update scan
try {
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
    Install-PackageProvider -Name NuGet -Force -Scope AllUsers -ErrorAction SilentlyContinue
    Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers -ErrorAction SilentlyContinue
    Import-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
    Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot -ErrorAction SilentlyContinue | Out-Null
    Log "Triggered Windows Update scan and install"
} catch {
    Log "Failed to trigger Windows Update scan"
    Log "================================================================="
    $ErrorMessage = "[$(Get-Date)] ERROR: $($_.Exception.Message)"
    Log "ERROR:"
    Log $ErrorMessage
}

Log "Remediation script completed."
