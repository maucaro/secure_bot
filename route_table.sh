#!/bin/bash
source ./setenv.sh

# Create a route table
az network route-table create -g ${RG_NAME} -n rt-${PREFIX}RouteTable

# Create a default route with 0.0.0.0/0 prefix and the next hop as the Azure firewall virtual appliance to inspect all traffic.
az network route-table route create -g ${RG_NAME} --route-table-name rt-${PREFIX}RouteTable -n default --next-hop-type VirtualAppliance --address-prefix 0.0.0.0/0 --next-hop-ip-address ${FW_INT_ADD}

# Associate the two subnets with the route table
az network vnet subnet update -g ${RG_NAME} -n ${SUBNET_INT_NAME} --vnet-name ${VNET_NAME} --route-table rt-${PREFIX}RouteTable

az network vnet subnet update -g ${RG_NAME} -n ${SUBNET_PVT_NAME} --vnet-name ${VNET_NAME} --route-table rt-${PREFIX}RouteTable