#!/bin/bash
# please do not edit this file or change filename
docker ps -a | grep -q hb_deploy
docker start hb_deploy