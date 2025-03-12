#!/bin/bash
source ./setenv.sh

BOT_VNET_RESOURCE_ID=$(az resource show --name ${VNET_NAME} --resource-group ${RG_NAME} --resource-type Microsoft.Network/virtualNetworks --query "id" | tr -d '"')
DBX_VNET_RESOURCE_ID=$(az resource show --name ${DBX_VNET_NAME} --resource-group ${DBX_RG_NAME} --resource-type Microsoft.Network/virtualNetworks --query "id" | tr -d '"')

## Create peering from vnet-1 to vnet-2. ##
az network vnet peering create --name ${VNET_NAME}-to-${DBX_VNET_NAME} \
    --vnet-name ${VNET_NAME} --resource-group ${RG_NAME} \
    --remote-vnet ${DBX_VNET_RESOURCE_ID}  \
    --allow-vnet-access --allow-forwarded-traffic

## Create peering from vnet-2 to vnet-1. ##
az network vnet peering create --name ${DBX_VNET_NAME}-to-${VNET_NAME} \
    --vnet-name ${DBX_VNET_NAME} --resource-group ${DBX_RG_NAME} \
    --remote-vnet ${BOT_VNET_RESOURCE_ID} \
    --allow-vnet-access --allow-forwarded-traffic

# Register DBX private DNS zone in Bot vnet
az network private-dns link vnet create --name dbx-vnet-link \
    --registration-enabled false \
    --resource-group ${DBX_RG_NAME} \
    --virtual-network ${BOT_VNET_RESOURCE_ID} \
    --zone-name ${DBX_PL_DNS_ZONE}