#=============================================================================================================================
#
# Script Name:     WinUpdate - Nuclear Reset.ps1
# Description:     Nuclear reset of Windows Update settings to allow Windows 11 upgrade.
#                  This script resets Windows Update settings, stops services, deletes cache, resets registry keys,
#                  and triggers a Windows Update scan to enable the Windows 11 upgrade offer.
# Notes:           This script is designed to be run with administrative privileges.

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

# Detection: Check if Windows 11 is already installed
$osVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
if ($osVersion -like "*Windows 11*") {
    Log "Windows 11 is already installed. No remediation needed."
    exit 0
}

# Compatibility check
function Test-Windows11Compatibility {
    $results = @{}
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force -ErrorAction SilentlyContinue
    # TPM 2.0
    try {
        $tpm = Get-WmiObject -Namespace "Root\\CIMv2\\Security\\MicrosoftTpm" -Class Win32_Tpm
        $results["TPM_2_0"] = $tpm.SpecVersion -match "2.0"
    } catch {
        $results["TPM_2_0"] = $false
    }

    # Secure Boot
    try {
        $results["SecureBoot"] = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
    } catch {
        $results["SecureBoot"] = $false
    }

    # UEFI
    try {
        $firmware = (Get-WmiObject -Class Win32_ComputerSystem).BootupState
        $results["UEFI"] = $firmware -match "EFI"
    } catch {
        $results["UEFI"] = $false
    }

    # RAM
    try {
        $ramGB = [math]::Round((Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
        $results["RAM_OK"] = $ramGB -ge 4
    } catch {
        $results["RAM_OK"] = $false
    }

    # Storage
    try {
        $storageGB = [math]::Round((Get-PSDrive -Name C).Free / 1GB, 2)
        $results["Storage_OK"] = $storageGB -ge 64
    } catch {
        $results["Storage_OK"] = $false
    }

    return $results
}

$compat = Test-Windows11Compatibility
$compat.Keys | ForEach-Object { Log "$_ check: $($compat[$_])" }

if ($compat.Values -contains $false) {
    Log "Device does not meet Windows 11 requirements. No Update Possible so no remediation will be run."
    exit 0
}

Log "Device is eligible for Windows 11 upgrade. Remediation required."
exit 1
