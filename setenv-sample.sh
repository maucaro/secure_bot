#!/bin/bash
# Declare variables (bash syntax)
export PREFIX='MauSecBot'
export RG_NAME='rg-'${PREFIX}
export VNET_NAME='vnet-'${PREFIX}
export SUBNET_INT_NAME='VnetIntegrationSubnet'
export SUBNET_PVT_NAME='PrivateEndpointSubnet'
export LOCATION='eastus2'
export TEAMS_IP_RANGE='52.112.0.0/14 52.122.0.0/15'
export FIREWALL_NAME='afw-'${LOCATION}'-'${PREFIX}
export VNET_CIDR='10.0.0.0/16'
export FW_SUBNET_CIDR='10.0.1.0/26'
export INTEGRATION_SUBNET_CIDR='10.0.2.0/24'
export ENDPOINT_SUBNET_CIDR='10.0.3.0/24'
export MANAGED_IDENTITY='msi-'${PREFIX}
export BOT_ID=${PREFIX}
export APP_SVC_NAME=${PREFIX}'-AS'
export SVC_PLAN_NAME=${PREFIX}'-SP'
export APP_SVC_NAME_LOWER=$(echo $APP_SVC_NAME | tr '[:upper:]' '[:lower:]')
export BOT_ENDPOINT='https://'${APP_SVC_NAME_LOWER}'.azurewebsites.net/api/messages'
export TENANT_ID=$(az account show --query "tenantId" | tr -d '"')

# TO DO: If networking parameters above change, the following values may need to be changed
export AS_PRIVATE_ADDR='10.0.3.4'
export FW_INT_ADD='10.0.1.4'

# Databricks (existing) resources
export DBX_RG_NAME='rg-GeniePoc'
export DBX_VNET_NAME='databricks-vnet'
export DBX_PL_DNS_ZONE='privatelink.azuredatabricks.net'

# Databricks Workspace and Genie settings
export DATABRICKS_SPACE_ID='REPLACE'
export DATABRICKS_HOST="REPLACE.azuredatabricks.net"
export DATABRICKS_TOKEN="REPLACE"
