#!/bin/bash
source ./setenv.sh

# Disable private endpoint network policies (this step is not required if you're using the Azure portal)
az network vnet subnet update --name ${SUBNET_PVT_NAME} --resource-group ${RG_NAME} --vnet-name ${VNET_NAME} --disable-private-endpoint-network-policies true

# Create the private endpoint
RESOURCE_ID=$(az resource show --name ${APP_SVC_NAME} --resource-group ${RG_NAME} --resource-type Microsoft.web/sites --query "id" | tr -d '"')
az network private-endpoint create --name pvt-${PREFIX}Endpoint --resource-group ${RG_NAME} --location ${LOCATION} --vnet-name ${VNET_NAME} --subnet ${SUBNET_PVT_NAME} --connection-name conn-${PREFIX} --private-connection-resource-id ${RESOURCE_ID} --group-id sites

# Create a private DNS zone to resolve the name of the app service
az network private-dns zone create --name ${PREFIX}privatelink.azurewebsites.net --resource-group ${RG_NAME}

az network private-dns link vnet create --name ${PREFIX}-DNSLink --resource-group ${RG_NAME} --registration-enabled false --virtual-network ${VNET_NAME} --zone-name ${PREFIX}privatelink.azurewebsites.net

az network private-endpoint dns-zone-group create --name chatBotZoneGroup --resource-group ${RG_NAME} --endpoint-name pvt-${PREFIX}Endpoint --private-dns-zone ${PREFIX}privatelink.azurewebsites.net --zone-name ${PREFIX}privatelink.azurewebsites.net

# Establish virtual network integration for outbound traffic
az webapp vnet-integration add -g ${RG_NAME} -n ${APP_SVC_NAME} --vnet ${VNET_NAME} --subnet ${SUBNET_INT_NAME}