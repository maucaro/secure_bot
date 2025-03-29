#!/bin/bash
source ./setenv.sh

az acr build --image ${CONTAINER_IMAGE_NAME} --registry ${REG_NAME} ./bot