#!/bin/bash
npm run build

# scp files to server
scp -r dist/ Dockerfile default.conf root@128.199.183.222:/opt/nodemcu/app_nodejs_nodemcu

# ssh and run shellscript to deploy
ssh root@128.199.183.222 "cd /opt/nodemcu; ./deploy-app.sh"

# delete dist folder
rm -rf dist