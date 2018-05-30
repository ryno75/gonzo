#!/bin/sh
export O365_API=http://o365/api/v1
export SECRET_SERVICE_API=http://secretserver-v2/api/v2
export REDIS=redis:6379
export STATE_MACHINE_ARN=arn:aws:states:us-west-2:721706031312:stateMachine:create_linked_account-prod
export AWS_ACCESS_KEY_ID=notreal
export AWS_SECRET_ACCESS_KEY=notsecure

/usr/local/bin/cla-ui
