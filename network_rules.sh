#!/bin/bash
source ./setenv.sh

# Create a NAT rule collection and a single rule. The source address is the public IP range of Microsoft Teams
# Destination address is that of the firewall. 
# The translated address is that of the app service's private link.
DEST_ADDR=$(az network public-ip show --name ${FIREWALL_NAME}-pip --resource-group ${RG_NAME} --query "ipAddress" | tr -d '"')  
az network firewall nat-rule create --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-nat-rules --priority 200 --action DNAT --source-addresses ${TEAMS_IP_RANGE} --dest-addr ${DEST_ADDR} --destination-ports 443 --firewall-name ${FIREWALL_NAME} --name rl-ip2appservice --protocols TCP --translated-address ${AS_PRIVATE_ADDR} --translated-port 443
# TO DO: In order to deploy (az webapp deploy...) and debug (az webapp log), a NAT rule is needed that allows traffic from the source(s)


# Create a network rule collection and add rules to it. 
# The first one is an outbound network rule to only allow traffic to the Teams IP range.
# The source address is that of the virtual network address space, destination is the Teams IP range.
az network firewall network-rule create --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-network-rules --priority 200 --action Allow --source-addresses ${VNET_CIDR} --dest-addr ${TEAMS_IP_RANGE} --destination-ports 443 --firewall-name ${FIREWALL_NAME} --name rl-OutboundTeamsTraffic --protocols TCP

# This rule will enable traffic to all IP addresses associated with Azure AD service tag
az network firewall network-rule create --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-network-rules --source-addresses ${VNET_CIDR} --dest-addr AzureActiveDirectory --destination-ports '*' --firewall-name ${FIREWALL_NAME} --name rl-AzureAD --protocols TCP

# This rule will enable traffic to all IP addresses associated with Azure Bot Services service tag
az network firewall network-rule create --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-network-rules --source-addresses ${VNET_CIDR} --dest-addr AzureBotService --destination-ports '*' --firewall-name ${FIREWALL_NAME} --name rl-AzureBotService --protocols TCP

# This rule will enable traffic to all IP addresses associated with Azure Databricks service tag
az network firewall network-rule create --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-network-rules --source-addresses ${VNET_CIDR} --dest-addr AzureDatabricks --destination-ports '*' --firewall-name ${FIREWALL_NAME} --name rl-AzureDatabricks --protocols TCP

# This rule will enable traffic to all IP addresses associated with Azure Container Registry service tag
az network firewall network-rule create --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-network-rules --source-addresses ${VNET_CIDR} --dest-addr AzureContainerRegistry --destination-ports '*' --firewall-name ${FIREWALL_NAME} --name rl-AzureContainerRegistry --protocols TCP

# Create an application rule collection and add rules to it. 
# This rule allows traffic to botframework.com
az network firewall application-rule create --firewall-name ${FIREWALL_NAME} --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-app-rules --priority 200 --action Allow --name rl-botframework --source-addresses ${VNET_CIDR} --protocols https=443 --target-fqdns '*.botframework.com'
# The following rules are needed by deploy (az webapp deploy...)
# TO DO: Add additional registries as needed
az network firewall application-rule create --firewall-name ${FIREWALL_NAME} --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-app-rules --name rl-Oryx --source-addresses ${VNET_CIDR} --protocols https=443 --target-fqdns oryx-cdn.microsoft.io
az network firewall application-rule create --firewall-name ${FIREWALL_NAME} --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-app-rules --name rl-PyPi --source-addresses ${VNET_CIDR} --protocols https=443 --target-fqdns pypi.org
az network firewall application-rule create --firewall-name ${FIREWALL_NAME} --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-app-rules --name rl-PythonHosted --source-addresses ${VNET_CIDR} --protocols https=443 --target-fqdns pythonhosted.org
az network firewall application-rule create --firewall-name ${FIREWALL_NAME} --resource-group ${RG_NAME} --collection-name coll-${PREFIX}-app-rules --name rl-PythonHosted-subs --source-addresses ${VNET_CIDR} --protocols https=443 --target-fqdns '*.pythonhosted.org'
