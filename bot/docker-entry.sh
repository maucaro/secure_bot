#!/bin/bash

if az login --identity --client-id ${MicrosoftAppId}; then
    echo az login successful 
else
    echo az login failed
fi

gunicorn --timeout 600 --access-logfile '-' --error-logfile '-' --bind 0.0.0.0:8080 --chdir /usr/src/app --worker-class aiohttp.worker.GunicornWebWorker app:APP
