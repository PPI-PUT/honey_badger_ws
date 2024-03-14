rocker --network host --privileged --nvidia --x11 --user --name honey_badger \
    --env "USER" \
    --env "RMW_IMPLEMENTATION=rmw_fastrtps_cpp" \
    --env "ROS_DOMAIN_ID=70" \
    --volume "${PWD}:${HOME}/${PWD##*/}" \
    --volume /dev/:/dev/ \
    --volume ~/.ssh:/home/${USER}/.ssh \
    -- macnack/honey_badger_project:humble
