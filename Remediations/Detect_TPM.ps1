#=============================================================================================================================
#
# Script Name:     Detect_TPM.ps1
# Description:     Detects TPM present and Ready. 
# Notes:           This is quite simple. IF TPM is ready to be used with Bitlocker (or Windows Hello), you'll see it as "No Issues."
#                  No Remediation is provided as of now, as often the issue is with manufacturers scripts needed. 
#
#=============================================================================================================================
#Copyright © 2023 José Pablo Cortés

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


$tpm = Get-Tpm
$tpmVersion = (wmic /namespace:\\root\cimv2\security\microsofttpm path win32_tpm get * /format:textvaluelist.xsl)

if($tpm.TpmPresent -eq "Yes"-and $tpm.TpmReady -eq "Yes"-and $tpm.TpmEnabled -eq "Yes"-and $tpm.TpmOwned -eq "Yes" -and [bool]($tpmVersion -match "SpecVersion=2.0")){
    exit 0
}
else{
    exit 1
}
