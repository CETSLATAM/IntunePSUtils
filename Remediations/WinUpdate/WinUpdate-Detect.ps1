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
    exit 1
}
