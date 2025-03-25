#!/bin/bash
source ./setenv.sh

# Create Azure Container Registry (ACR)
az acr create -n ${REG_NAME} -g ${RG_NAME} --sku Standard

# Set Web App's source to container in ACR
az webapp config container set --name ${APP_SVC_NAME} --resource-group ${RG_NAME} --container-image-name ${CONTAINER_IMAGE_NAME}

# Authorize the managed identity for your registry & configure Web App
REG_ID=$(az acr show --resource-group ${RG_NAME} --name ${REG_NAME} --query id --output tsv)
PRINCIPAL_ID=$(az identity show --resource-group ${RG_NAME} --name ${MANAGED_IDENTITY} --query principalId --output tsv)
CLIENT_ID=$(az identity show --resource-group ${RG_NAME} --name ${MANAGED_IDENTITY} --query clientId --output tsv)
az role assignment create --assignee ${PRINCIPAL_ID} --scope ${REG_ID} --role "AcrPull"
az webapp config set --resource-group ${RG_NAME} --name ${APP_SVC_NAME} --generic-configurations '{"acrUseManagedIdentityCreds": true}'
az webapp config set --resource-group ${RG_NAME} --name ${APP_SVC_NAME} --generic-configurations "{\"AcrUserManagedIdentityID\": \"${CLIENT_ID}\"}"
az webapp log config --name ${APP_SVC_NAME} --resource-group ${RG_NAME} --docker-container-logging filesystem

# Build image TO DO
az acr build --image ${CONTAINER_IMAGE_NAME} --registry ${REG_NAME} .