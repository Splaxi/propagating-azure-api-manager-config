# Propagating Azure API Management Configuration 
This repo contains PowerShell scripts to help any looking to use the Azure API Management DevOps Resource Kit (https://github.com/Azure/azure-api-management-devops-resource-kit)

The four scripts in this repository help users to extract, update and deploy Azure APIM configuration between instances. The basic functionality of these scripts are as follows:

1. Extract.ps1 - Download Release 5.0 of the Azure API Management DevOps Resource Kit and extract the configurtation of the source APIM ipdanstance.
2. UpdateSourceTarget.ps1 - Updates the reference from the source APIM instance and resource group to the target APIM instance and resource group
3. UpdateSecrets.ps1 - Removes references to client secret values and named secret values
4. Deploy.ps1 - Sample deployment script for the linked ARM templates produced during the extraction

# Addition Information
Please see the following blog post for additional information - https://www.keithjenneke.com/propagating-azure-apim-config

# References 
1. https://github.com/Azure/azure-api-management-devops-resource-kit