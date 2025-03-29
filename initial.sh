#!/bin/bash
source ./setenv.sh

# Create a resource group
az group create --name ${RG_NAME} --location ${LOCATION}

# Create the managed identity
az identity create --resource-group ${RG_NAME} --name ${MANAGED_IDENTITY}

# Create Azure Container Registry (ACR)
az acr create -n ${REG_NAME} -g ${RG_NAME} --sku Standard

# Authorize the managed identity to pull from the registry 
PRINCIPAL_ID=$(az identity show --resource-group ${RG_NAME} --name ${MANAGED_IDENTITY} --query principalId --output tsv)
REG_ID=$(az acr show --resource-group ${RG_NAME} --name ${REG_NAME} --query id --output tsv)
az role assignment create --assignee ${PRINCIPAL_ID} --scope ${REG_ID} --role "AcrPull"