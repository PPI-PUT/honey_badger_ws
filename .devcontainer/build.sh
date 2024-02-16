DOCKER_BUILDKIT=1 docker build --network=host \
    --build-arg WORKSPACE=ros2_ws \
    -t amadeuszsz/ros2_project:humble .
