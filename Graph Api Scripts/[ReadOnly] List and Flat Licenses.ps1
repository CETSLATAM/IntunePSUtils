<#
Title: List and flatten Subscribed User licenses. 
Requires: Graph API, PS Graph SDK 2.10.0
Author: José Pablo Cortés
License: MIT
opyright © 2023 José Pablo Cortés

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), 
to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
IN THE SOFTWARE.
#>
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Connect-MgGraph -Scopes "Directory.Read.All"

$licenses = Get-MgSubscribedSku -All
#We don't want the licenses that are tenant-wide. 
$userLicenses = $licenses | Where-Object AppliesTo -EQ "User" | Select-Object ConsumedUnits, SkuId, SkuPartNumber, PrepaidUnits 
$FlatLicenses = @() #Array to hold the objects below
#Flatten, and ignore the Service Plans 
foreach ($lic in $userLicenses){
    $flatlicense = [PSCustomObject]@{
        SKU = $lic.SkuPartNumber;
        Enabled = $lic.PrepaidUnits.Enabled;
        Consumed = $lic.ConsumedUnits;
        LockedOut = $lic.PrepaidUnits.LockedOut;
        Suspended = $lic.PrepaidUnits.Suspended;
        Warning = $lic.PrepaidUnits.Warning;
    }
    $Flatlicenses += $flatlicense;
}

$FlatLicenses | ft
#here you can pipe out somewhere else, save as CSV or Json, or just leave it as is and see it on the screen 