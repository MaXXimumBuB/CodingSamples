<#
.SYNOPSIS
    Script to ping servers and get hostnames.

.DESCRIPTION
    Script will pull a list of IPs from a file and test to see if a machine is online by pinging it.  If it is successful, it adds the IP Address and the hostname of the machine to its respective hash table and exports it to a data sheet.  A quick summary is printed out to the terminal for viewing.

.NOTES
    Author: Chris Cardi
    Date: 7/14/24
    'Find-Computer' is a cmdlet written by a colleague to assist with locating a machine across multiple domains.
    
    *Any specifically identifying code has been changed to a random value for security.*
#>

# Setup files for input and output
$getFile = "C:\PATH_TO\FILE"
$IPs = get-content $getFile
$fileDate = Get-Date -UFormat '%Y%m%d_%H%M%S'
$outputFile = "C:\PATH_TO\FILE-$($fileDate)"

# Create hash tables to collect key / value pairs
$pingAndName = @{}
$noPingAndName = @{}
$pingAndNoName = @()
$noPingAndNoName = @()
$AllResolved = @{}
$MysteryMachines = @()
$MysteryMachinesNo = @()

# Properties of each machine to pull from AD
$compProps = @(
    'Name',
    'IPv4Address',
    'LastLogonDate',
    'ManagedBy',
    'Info',
    'Description',
    'Location'
)

# Check the if the IP Address is online, and if so, attempt to get the name and add it to its respective hash table
foreach ($IP in $IPs) {
    Write-PSFMessage -Message "Checking IP <c='yellow'>$($IP)</c>..." -Level 1
    $pingIP = Test-Connection $IP -Count 1
    $getName = Resolve-DnsName $IP -ErrorAction SilentlyContinue

    if ($pingIP.Status -eq "Success" -and $getName.NameHost) {
        $pingAndName.Add($IP, $getName.NameHost)
        $AllResolved.Add($IP, $getname.NameHost)
    } elseif ($pingIP.Status -eq "TimedOut" -and $getName.NameHost) {
        $noPingAndName.Add($IP, $getName.NameHost)
        $AllResolved.Add($IP, $getname.NameHost)
    } elseif ($pingIP.Status -eq "Success" -and !($getName)) {
        $pingAndNoName += $IP
    } else {
        $noPingAndNoName += $IP
    }
}

# Collect information for each machine from AD
foreach ($name in $AllResolved.values.GetEnumerator()) {
    $ServerName = $name.Substring(0, $name.IndexOf('.'))
    if ($ServerName) {
        Write-PSFMessage -Message "Getting information for <c='green'>$($ServerName)</c>..." -Level 1
        $getComputer = Find-Computer -computerName $ServerName -ComputerProperties $compProps 
        if ($getComputer) {
            $MysteryMachines += $getComputer
        } else {
            Write-PSFMessage -Message "<c='red'>$($ServerName) not found anywhere</c>"
            $MysteryMachinesNo += $ServerName
        }
    } else {
        Write-PSFMessage -Message "<c='red'>Wasn't able to parse $($ServerName)</c>"
    }
}

# Short summary printed to terminal for quick review
Write-PSFMessage -Message "<c='green'>Out of a total</c> <c='white'>$($IPs.Count)</c> <c='green'>IP addresses:</c>
                                <c='white'>$($pingandname.Count + $pingandnoname.Count)</c> are <c='white'>PINGING</c>
                                <c='red'>$($noPingAndName.Count + $noPingAndNoName.Count)</c> are <c='red'>NOT PINGING</c>
                                <c='white'>$($pingAndName.Count + $noPingAndName.Count)</c> are <c='white'>RESOLVING</c>
                                <c='red'>$($pingandnoname.count + $noPingAndNoName.Count)</c> are <c='red'>NOT RESOLVING</c>" -Level 1

# Export respective information to datasheet
$pingAndName.GetEnumerator() | select Key,Value | Export-Excel -Path $outputFile -worksheetname "Pings-HasName" -FreezeTopRow -AutoSize -clearsheet
$noPingAndName.GetEnumerator() | select Key,Value | Export-Excel -Path $outputFile -worksheetname "NoPing-HasName" -AutoSize -clearsheet
$pingAndNoName | Export-Excel -Path $outputFile -worksheetname "Pings-NoName" -AutoSize -clearsheet
$noPingAndNoName | Export-Excel -Path $outputFile -worksheetname "NoPing-NoName" -AutoSize -clearsheet
$AllResolved.GetEnumerator() | select Value | Export-Excel -Path $outputFile -WorksheetName "All-Names" -AutoSize -clearsheet
$MysteryMachines | Select $compProps | Export-Excel -Path $outputFile -worksheetname "Server-INFO" -BoldTopRow -FreezeTopRow -AutoSize -AutoFilter -clearsheet
$MysteryMachinesNo | Export-Excel -Path $outputFile -worksheetname "Not in AD" -AutoSize -Show -clearsheet


#NOTES
# $Department = $AllResolved.Values.GetEnumerator().replace('.', '').replace('OU=', '').split(',')