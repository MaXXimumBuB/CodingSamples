#Region Authenticate
$FalconCloud = 'NAMEOFCLOUD'
$FalconToken = Test-FalconToken -ErrorAction SilentlyContinue
$FalconU = Get-Secret -Name "SECRETNAME" | ConvertFrom-SecureString -AsPlainText
$FalconP = Get-Secret -Name "SECRETPASSWORD" | ConvertFrom-SecureString -AsPlainText

if (($FalconToken).token -eq $false -or $null -eq $FalconToken){
    Request-FalconToken -ClientId $FalconU -ClientSecret $FalconP -Cloud $FalconCloud
}

if (Test-FalconToken) {
    write-host -foregroundcolor Green "-=-=-=-=- Token is ON - Begin. -=-=-=-=-"
}
#EndRegion Authenticate

#Region NOTES
<# OLD CODE

if ($null -eq $FalconClientID) {
    $FalconClientID = Read-Host -Prompt 'Please enter the API ID' -MaskInput
}
if ($null -eq $FalconClientSecret) {
    $FalconClientSecret = Read-Host -Prompt 'Please enter the Secret for the API' -MaskInput
}
if (($FalconToken).token -eq $false -or $null -eq $FalconToken) {
    Request-FalconToken -ClientId $FalconClientID -ClientSecret $FalconClientSecret -Cloud $FalconCloud
}
#>

#EndRegion NOTES