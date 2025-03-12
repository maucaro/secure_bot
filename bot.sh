#!/bin/bash
source ./setenv.sh

APP_ID=$(az identity show --resource-group ${RG_NAME} --name ${MANAGED_IDENTITY} --query "clientId" | tr -d '"')

az deployment group create --resource-group ${RG_NAME} \
    --template-file ./deployUseExistResourceGroup/template-BotApp-with-rg.json \
    --parameters ./deployUseExistResourceGroup/parameters-for-template-BotApp-with-rg.json \
    --parameters appServiceName=${APP_SVC_NAME} newAppServicePlanName=${SVC_PLAN_NAME} newAppServicePlanLocation=${LOCATION} appId=${APP_ID} UMSIName=${MANAGED_IDENTITY} UMSIResourceGroupName=${RG_NAME} tenantId=${TENANT_ID} \
                 DATABRICKS_SPACE_ID=${DATABRICKS_SPACE_ID} DATABRICKS_HOST=${DATABRICKS_HOST} DATABRICKS_TOKEN=${DATABRICKS_TOKEN}

az deployment group create --resource-group ${RG_NAME} \
   --template-file ./deployUseExistResourceGroup/template-AzureBot-with-rg.json \
   --parameters ./deployUseExistResourceGroup/parameters-for-template-AzureBot-with-rg.json \
   --parameters azureBotId=${PREFIX} botEndpoint=${BOT_ENDPOINT} appId=${APP_ID} UMSIName=${MANAGED_IDENTITY} UMSIResourceGroupName=${RG_NAME} tenantId=${TENANT_ID}