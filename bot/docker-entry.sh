#!/bin/bash

if az login --identity --client-id 'c11c8c88-3bd4-40e4-9b49-dc5a1721e46b'; then
    echo az login successful 
else
    echo az login failed
fi

gunicorn --timeout 600 --access-logfile '-' --error-logfile '-' --bind 0.0.0.0:8080 --chdir /usr/src/app --worker-class aiohttp.worker.GunicornWebWorker app:APP
