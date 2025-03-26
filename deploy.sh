#!/bin/bash
source ./setenv.sh
cd ./bot
rm ./deploy.zip
zip -X ./deploy.zip app.py config.py requirements.txt web.config
cd ..
az webapp deploy --resource-group ${RG_NAME} --name ${APP_SVC_NAME} --src-path ./bot/deploy.zip --async