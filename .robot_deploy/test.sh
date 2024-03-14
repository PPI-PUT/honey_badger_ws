#!/bin/bash
docker run --rm --network host --privileged     --name hb_deploy_test     --env RMW_IMPLEMENTATION=rmw_fastrtps_cpp     --env ROS_DOMAIN_ID=70     macnack/hb_deploy:humble bash
