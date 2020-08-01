param(
    [Parameter()]
    [string]$myResourceGroup,

    [Parameter()]
    [string]$myApimInstance
)

New-Item -Path $PSScriptRoot -Name "temp" -ItemType "directory"
New-Item -Path $PSScriptRoot -Name "extracted" -ItemType "directory"
New-Item -Path "$PSScriptRoot\temp" -Name "reskit-win64" -ItemType "directory"

$extLocation = "$PSScriptRoot\extracted"

# Download Release 5 of the azure-api-management-devops-resource-kit
$url = "https://github.com/Azure/azure-api-management-devops-resource-kit/releases/download/v0.5/reskit-win64.zip"
$output = "$PSScriptRoot\temp\reskit-win64.zip"
$start_time = Get-Date

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $output

Write-Output "Time taken $((Get-Date).Subtract($start_time).Seconds) seconds(s)"

# Extract Release 5 of the azure-api-management-devops-resource-kit
Set-Location "$PSScriptRoot\temp\reskit-win64"
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PSScriptRoot\temp\reskit-win64.zip", "$PWD")

# Extract APIM Instance
Set-Location "$PSScriptRoot\temp\reskit-win64\win64"
.\apimtemplate.exe extract --sourceApimName $myApimInstance --destinationApimName DEST-APIM --resourceGroup $myResourceGroup --fileFolder $extLocation --baseFileName APIM --splitAPIs true --paramServiceUrl true --linkedTemplatesBaseUrl $extLocation --linkedTemplatesSasToken $extLocation --policyXMLBaseUrl $extLocation --policyXMLSasToken $extLocation