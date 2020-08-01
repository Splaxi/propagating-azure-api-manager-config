$myGuid1 = Get-Random

$myResourceGroup = ""
$myLocation = "australiaeast"

$myStorageAccount = "stdeployment$myGuid1"
$mySku = "Standard_GRS"
$myStorageContainer = "apim-deployment"

$myLinkedTemplates = "$PSScriptRoot\extracted"

$myTemplateFile = "$PSScriptRoot\extracted"
$myTemplateParameterFile = "$PSScriptRoot\extracted"

$myApiService = ""
$myContainerEndpoint = "https://$myStorageAccount.blob.core.windows.net/$myStorageContainer"
$myContianerPolicyEndpoint = "$myContainerEndpoint/policies"
$myServiceUrl = @{
    api1 = ""
    api2 = ""
    api3 = ""
}

# Check Az Context
$azContext = Get-AzContext | Select-Object -ExpandProperty Name
$subscriptionName = $azContext.split("(")[0]
Write-Output "#### Starting Deployment #####"
Write-Output ""
Write-Output "Your are connected to the following subscription: $subscriptionName"
Write-Output ""

# Prompt user to confirm continuation of deployment
$title    = ''
$question = 'Are you sure you want to proceed with this deployment?'
$choices  = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
} else {
    Write-Host 'cancelled'
    Exit
}

# Create new storage account 
Write-Output "#### Creating a temporary Storage Account #####"
Write-Output ""
New-AzStorageAccount -ResourceGroupName $myResourceGroup -AccountName $myStorageAccount -Location $myLocation -SkuName $mySku
Write-Output ""

# Get storage key for storage account
Write-Output "#### Getting storage key for temporary Storage Account #####"
Write-Output ""
$stKey1 = (Get-AzStorageAccountKey -ResourceGroup $myResourceGroup -AccountName $myStorageAccount ) | Where-Object {$_.KeyName -eq "key1"} | Select-Object -ExpandProperty Value
Write-Output ""
Write-Output "The storage key is: $stKey1"
Write-Output ""

# Create storage context
Write-Output "#### Creating storage context for temporary Storage Account #####"
Write-Output ""
$storageContext = New-AzStorageContext -StorageAccountName $myStorageAccount -StorageAccountKey $stKey1

# Create a storage container on temporary storage account
Write-Output "#### Creating a storage container on temporary Storage Account #####"
Write-Output ""
New-AzStorageContainer -Name $myStorageContainer -Context $storageContext
Write-Output ""

# Copy Linked Templates to storage container on temporary storage
Write-Output "#### Creating a storage container on temporary Storage Account #####"
Write-Output ""
Get-ChildItem -Path $myLinkedTemplates -File -Recurse | Set-AzStorageBlobContent -Context $storageContext -Container $myStorageContainer
Write-Output ""

# Generate Shared Access Signature (SAS) token
Write-Output "#### Generating SAS Token to storage container on temporary Storage Account #####"
Write-Output ""
$stContainerSASToken = New-AzStorageContainerSASToken -Name $myStorageContainer -Permission rwdl -Context $storageContext
Write-Output ""
Write-Output "The Storage Container SAS token is: $stContainerSASToken"
Write-Output ""

# Deploy ARM templates to create the APIM Configuration
Write-Output "#### Deploy ARM templates to create APIM Configuration #####"
Write-Output ""
New-AzResourceGroupDeployment -ResourceGroupName $myResourceGroup -TemplateFile $myTemplateFile -TemplateParameterFile $myTemplateParameterFile -ApimServiceName $myApiService -LinkedTemplatesBaseUrl $myContainerEndpoint -LinkedTemplatesSasToken $stContainerSASToken  -PolicyXMLBaseUrl $myContianerPolicyEndpoint -ServiceUrl $myServiceUrl 
Write-Output ""

#Clean up storage
Write-Output "#### Removing temporary storage account #####"
Write-Output ""
Remove-AzStorageAccount -ResourceGroupName $myResourceGroup -AccountName $myStorageAccount
Write-Output ""
Write-Output "Completed successfully!!"