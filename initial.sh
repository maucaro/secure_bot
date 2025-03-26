#!/bin/bash
source ./setenv.sh

# Create a resource group
az group create --name ${RG_NAME} --location ${LOCATION}

# Create managed identity
az identity create --resource-group ${RG_NAME} --name ${MANAGED_IDENTITY}

# Create a virtual network with a subnet for the firewall
az network vnet create --name ${VNET_NAME} --resource-group ${RG_NAME} --location ${LOCATION} --address-prefix ${VNET_CIDR} --subnet-name ${SUBNET_FW_NAME} --subnet-prefix ${FW_SUBNET_CIDR}

# Add a subnet for the Virtual network integration
az network vnet subnet create --name ${SUBNET_INT_NAME} --resource-group ${RG_NAME} --vnet-name ${VNET_NAME} --address-prefix ${INTEGRATION_SUBNET_CIDR}

# Add a subnet where the private endpoint will be deployed for the app service
az network vnet subnet create --name ${SUBNET_PVT_NAME} --resource-group ${RG_NAME} --vnet-name ${VNET_NAME} --address-prefix ${ENDPOINT_SUBNET_CIDR}

# Create a firewall, enable DNS proxy & sconfigure the vnet to use Azure Firewall as the DNS server 
az network firewall create --name ${FIREWALL_NAME} --resource-group ${RG_NAME} --location ${LOCATION}
az network firewall update --name ${FIREWALL_NAME} --resource-group ${RG_NAME} --enable-dns-proxy true
az network vnet update --name ${VNET_NAME} --resource-group ${RG_NAME} --dns-servers ${FW_INT_ADD}

# Create a public IP for the firewall
az network public-ip create --name ${FIREWALL_NAME}-pip --resource-group ${RG_NAME} --location ${LOCATION} --allocation-method static --sku standard

# Associate the IP with the firewall
az network firewall ip-config create --firewall-name ${FIREWALL_NAME} --name ${FIREWALL_NAME}-Config --public-ip-address ${FIREWALL_NAME}-pip --resource-group ${RG_NAME} --vnet-name ${VNET_NAME}

# Update the firewall
az network firewall update --name ${FIREWALL_NAME} --resource-group ${RG_NAME}
