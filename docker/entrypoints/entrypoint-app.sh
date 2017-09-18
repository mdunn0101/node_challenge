#!/bin/bash

if [ -f /run/secrets/s3_secrets_production ]
then
  source /run/secrets/s3_secrets_production
fi

dockerize -wait http://mongo:27017 -timeout 30s /usr/local/bin/npm start
