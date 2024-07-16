<#
.SYNOPSIS
    Script to get properties of machines in AD.

.DESCRIPTION
    Script will take in data from a list of machine names and query AD for the requested properties.  It will then export that list to a datasheet and create tabs in the data sheet if it was found in AD or not.

.NOTES
    Author: Chris Cardi
    Date: 7/14/24
    'Find-Computer' is a cmdlet written by a colleague to assist with locating a machine across multiple domains.
#>

# Setup input and output information
$getFile = "C:\PATH_TO\FILE"
$computers = get-content $getFile
$fileDate = Get-Date -UFormat '%Y%m%d_%H%M%S'
$outputFile = "C:\PATH_TO\\$($FileDate)_FILE"

# Create Arrays to collect information
$MysteryMachines = @()
$MysteryMachinesNo = @()

$compProps = @(
    'Name',
    'OperatingSystem',
    'IPv4Address',
    'LastLogonDate',
    'ExtensionAttribute4',
    'ExtensionAttribute8',
    'ExtensionAttribute10',
    'ExtensionAttribute11',
    'ManagedBy',
    'Info',
    'Description',
    'Location'
)

foreach ($computer in $computers) {
    write-host -ForegroundColor Green "Getting info for $($computer)"
    $getComputer = Find-Computer -computerName $computer -ComputerProperties $compProps
    if ($getComputer) {
        $MysteryMachines += $getComputer
    } else {
        write-host -foregroundcolor Red "$($computer) not found anywhere"
        $MysteryMachinesNo += $computer
    }
}

$MysteryMachines | Select $compProps | Export-Excel -Path $outputFile -worksheetname "Found in AD" -BoldTopRow -FreezeTopRow -AutoSize -AutoFilter -Show -clearsheet -TableName "Mystery Machines"
$MysteryMachinesNo | Export-Excel -Path $outputFile -worksheetname "Not in AD" -AutoSize -Show -clearsheet