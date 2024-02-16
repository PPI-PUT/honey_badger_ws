DOCKER_BUILDKIT=1 docker build --network=host \
    --build-arg WORKSPACE=ros2_ws \
    -t macnack/honey_badger_project:humble .
