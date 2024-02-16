#!/bin/bash
set -e

if [ -f /opt/ros/humble/setup.bash ]; then source /opt/ros/humble/setup.bash; fi
vcs import < default.repos
sudo apt-get update
rosdep update
rosdep install --from-paths src --ignore-src -y
