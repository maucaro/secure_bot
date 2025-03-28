#!/bin/bash
source ./setenv.sh

# Create a resource group
az group create --name ${RG_NAME} --location ${LOCATION}

# Create managed identity
az identity create --resource-group ${RG_NAME} --name ${MANAGED_IDENTITY}