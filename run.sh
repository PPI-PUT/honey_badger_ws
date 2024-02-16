rocker --network host --privileged --nvidia --x11 --user --name ros_container \
    --env "USER" \
    --env "RMW_IMPLEMENTATION=rmw_fastrtps_cpp" \
    --env "ROS_DOMAIN_ID=0" \
    --volume "${PWD}:${HOME}/${PWD##*/}" \
    --volume /dev/:/dev/ \
    -- amadeuszsz/ros2_project:humble 
