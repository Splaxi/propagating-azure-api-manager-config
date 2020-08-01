# Name: Update Client Secret function
# Author: Keith Jenneke
# Created: 01/08/2020

#### Start Update Client Secret Function ####
# This function normalises the openidconnect
# and authorizations ARM templates
#
function Update-ClientSecret {
Param ([string] $filePath, [string]$jsonFileName, [string]$jsonFile)

# Temp file
$jsonTempFile = "$PSScriptRoot\TEMP-$jsonFileName"

# Final file
$jsonFileOut = "$PSScriptRoot\$jsonFileName"

# Get contents of source file
$jsonContent = Get-Content -Path $jsonFile

# Convert form json to a custom PS Object
$jsonAsPsObject = $jsonContent | ConvertFrom-Json

# Create JSON object for Client Secret parameter
$snippetJson1 = @'
{
    "Type": "String"
}
'@

# Convert JSON object to PSObject
$resource = $snippetJson1 | ConvertFrom-Json

# Add parameter property to file content 
$jsonAsPsObject.parameters | Add-member -MemberType NoteProperty -Name "clientSecret" -Value $resource

# Update clientSecret value to parameter
ForEach ($property in $jsonAsPsObject.resources.properties) {
    $property.clientSecret="[parameters('clientSecret')]"
}

# Save update content as temp json file 
$jsonAsPsObject | ConvertTo-Json -depth 100 | Set-Content $jsonTempFile

# Remove unwanted characters add during PS convertion
$jsonTempFile | ConvertTo-Json -Depth 100 | Out-File $jsonFileOut -Force
     # Unwanted Pattern
    $ReplacePatterns = @{
    "\\u003c" = "<"
    "\\u003e" = ">"
    "\\u0027" = "'"
    }
    # Convert file content to string and find and remove pattern
    $InputJson = Get-Content -Path $jsonTempFile | Out-String
    foreach ($Pattern in $ReplacePatterns.GetEnumerator())
    {
        $InputJson = $InputJson -replace $Pattern.Key, $Pattern.Value
    }
    # Save updated content to new json file
    $InputJson | Out-File -FilePath $jsonFileOut

    Remove-item $jsonFile 
    Copy-item $jsonFileOut -Destination $filePath
    Remove-item $jsonTempFile, $jsonFileOut
}
#
#### End Update Client Secret function ####

#### Start Update Secret Function ####
# This function normalises the namedValues
# ARM template
#
function Update-Secret {
Param ([string] $filePath, [string]$jsonFileName, [string]$jsonFile)

# Temp file
$jsonTempFile = "$PSScriptRoot\TEMP-$jsonFileName"

# Final file
$jsonFileOut = "$PSScriptRoot\$jsonFileName"

# Get contents of source file
$jsonContent = Get-Content -Path $jsonFile

# Convert form json to a custom PS Object
$jsonAsPsObject = $jsonContent | ConvertFrom-Json

# Create JSON object for Client Secret parameter
$snippetJson1 = @'
{
    "Type": "String"
}
'@

# Convert JSON object to PSObject
$resource = $snippetJson1 | ConvertFrom-Json

# Add parameter property to file content 
$jsonAsPsObject.parameters | Add-member -MemberType NoteProperty -Name "secretValue" -Value $resource

# Update clientSecret value to parameter
ForEach ($property in $jsonAsPsObject.resources.properties) {
    $property.value="[parameters('secretValue')]"
}

# Save update content as temp json file 
$jsonAsPsObject | ConvertTo-Json -depth 100 | Set-Content $jsonTempFile

$jsonTempFile | ConvertTo-Json -Depth 100 | Out-File $jsonFileOut -Force
     # Unwanted Pattern
    $ReplacePatterns = @{
    "\\u003c" = "<"
    "\\u003e" = ">"
    "\\u0027" = "'"
    }
    # Convert file content to string and find and remove pattern
    $InputJson = Get-Content -Path $jsonTempFile | Out-String
    foreach ($Pattern in $ReplacePatterns.GetEnumerator())
    {
        $InputJson = $InputJson -replace $Pattern.Key, $Pattern.Value
    }
    # Save updated content to new json file
    $InputJson | Out-File -FilePath $jsonFileOut

    Remove-item $jsonFile 
    Copy-item $jsonFileOut -Destination $filePath
    Remove-item $jsonTempFile, $jsonFileOut
}
#
#### End Update Secret function ####

$filePath = "$PSScriptRoot\extracted"
$openIdConnectFile = "APIM-openidconnect.template.json"
$authorisationServersFile = "APIM-authorizationServers.template.json"
$namedValueFile = "APIM-namedValues.template.json"

$files = @($openIdConnectFile, $authorisationServersFile)

ForEach ($file in $files){
$jsonFileName = $file
$jsonFile = "$filePath\$file"
Update-ClientSecret $filePath $jsonFileName $jsonFile 
}

$jsonFileName = $namedValueFile
$jsonFile = "$filePath\$jsonFileName"

Update-Secret $filePath $jsonFileName $jsonFile