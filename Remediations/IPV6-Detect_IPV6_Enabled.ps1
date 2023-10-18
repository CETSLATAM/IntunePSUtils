#=============================================================================================================================
#
# Script Name:     Detect_IPV6_Enabled.ps1
# Description:     Detects IPV6 component enabled on any Network Interface
# Notes:           Microsoft DOES NOT RECOMMEND disabiling IPV6, neither for troubleshooting nor Security. There are other ways.
#                  This Script tho, will detec any network interface running IPV6. See other Remediation
#
#=============================================================================================================================
<#
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


#>


#LAST CHANCE: PLEASE DO NOT DISABLE IPV6. This is the very last option for troubleshooting. 


$res = Get-NetAdapterBinding -ComponentID ms_tcpip6
$errors = $false
foreach ($adapter in $res){
    if($adapter.Enabled -eq $true){        
        $errors = $true
    }
}
if($errors){
    exit 1
    }
exit 0

