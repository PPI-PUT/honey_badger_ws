#!/bin/bash
ROS_DOMAIN_ID="70"
docker run -it --network host --privileged \
    --name hb_deploy \
    --env RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
    --env ROS_DOMAIN_ID=$ROS_DOMAIN_ID \
    --volume /dev/:/dev/ \
    macnack/hb_deploy:humble bash
