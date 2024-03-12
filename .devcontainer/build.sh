DOCKER_BUILDKIT=1 docker build --network=host \
    --build-arg WORKSPACE=honey_badger_ws \
    -t macnack/honey_badger_project:humble .
