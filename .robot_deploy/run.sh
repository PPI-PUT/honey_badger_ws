#!/bin/bash
docker run -it --network host --privileged     --name hb_deploy     --env RMW_IMPLEMENTATION=rmw_fastrtps_cpp     --env ROS_DOMAIN_ID=70     --volume /dev/:/dev/     macnack/hb_deploy:humble bash
