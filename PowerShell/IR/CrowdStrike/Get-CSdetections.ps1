<#
.SYNOPSIS
    Script to retrieve all CrowdStrike Detections within the last 30 days.

.DESCRIPTION
    Script will pull information via CrowdStrike API all the detections found in the environment in the past 30 days.  The information requested are the ones listed in $ExcelProperties

.NOTES
    Author: Chris Cardi
    Date: 7/14/24

.EXAMPLE
    $item = @()
    foreach ($detection in $detections) { 
        $item += ($detection.behaviors | Select-Object $ExcelProperties)
    }
    
    Will get all the detections, pull all the property information, and then export it to a file.
#>

$outputPath = "C:\PATH_TO\FILE"

# Check if the file already exists; Remove it if it does 
if (Test-Path $outputPath) { 
    Write-Host -foregroundcolor Red "Found file. Removing it." 
    Remove-Item $outputPath -Force 
} 

# Formatting it this way will remove 'System.Object[]' from output
# Properties to be included in report
$ExcelProperties = @(
    'Timestamp'
    @{l='hostname';e={$detection.device.hostname}}
    @{l='Domain';e={$detection.device.machine_domain}}
    'User_Name'
    @{l='OS Version';e={$detection.device.os_version}}
    @{l='Last Seen';e={$detection.device.last_seen}}
    'Filename'
    'Filepath'
    'Alleged_Filetype'
    'CMDLine'
    'Technique'
    'Severity'
    'IOC_Type'
    'IOC_Value'
    'IOC_Source'
    'IOC_Description'
    @{l='mac_address';e={$detection.device.mac_address}}
    @{l='local_ip';e={$detection.device.local_ip}}
    @{l='external_ip';e={$detection.device.external_ip}}
)

#Code from PSFalcon to get detections from Domain in the last 30 days
$detections = Get-FalconDetection -Filter "created_timestamp:>'Last 30 days'+device.machine_domain:'NAME_OF_DOMAIN'" -Detailed -All

# Array to hold all info on detections
$item = @()
foreach ($detection in $detections) { 
    $item += ($detection.behaviors | Select-Object $ExcelProperties)
}

$item | Export-Excel $outputPath -TableName 'Detections'-WorksheetName 'Detections' -AutoSize -AutoFilter -FreezeTopRow -BoldTopRow -ClearSheet -Show


#Region NOTES
<#

Must be made into a sub-expression so that the output can be exported using pipe

$(foreach ($detection in $detections) { 
    $detection.behaviors | Select $ExcelProperties 
    }) | Export-Excel $outputPath -TableName 'Detections'-WorksheetName 'Detections' -AutoSize -AutoFilter -FreezeTopRow -BoldTopRow -ClearSheet -Show

#>

#EndRegion NOTES
