#!/bin/bash
docker run --rm --network host --privileged     --name hb_deploy_test     --env RMW_IMPLEMENTATION=rmw_fastrtps_cpp     --env ROS_DOMAIN_ID=70     macnack/hb_deploy:humble bash
if docker ps -a | grep -q hb_deploy; then
    echo "Old container hb_deploy is running."
    echo "Stopping and removing old container."
    docker stop hb_deploy
    docker rm hb_deploy
else
    echo "Container hb_deploy is not running. \n Starting run.sh."
fi
