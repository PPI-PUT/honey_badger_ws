FROM ros:humble-ros-base
ARG WORKSPACE
ENV WORKSPACE=${WORKSPACE} \
    AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1 \
    AMENT_PREFIX_PATH=/opt/ros/humble \
    COLCON_PREFIX_PATH=/opt/ros/humble \
    DEBIAN_FRONTEND=noninteractive \
    LD_LIBRARY_PATH=/opt/ros/humble/lib \
    NVIDIA_DRIVER_CAPABILITIES=all \
    NVIDIA_VISIBLE_DEVICES=all \
    PATH=/opt/ros/humble/bin:$PATH \
    PYTHONPATH=/opt/ros/humble/lib/python3.10/site-packages:/opt/ros/humble/local/lib/python3.10/dist-packages \
    QT_X11_NO_MITSHM=1 \
    ROS_DISTRO=humble \
    ROS_PYTHON_VERSION=3 \
    ROS_VERSION=2 


# install packages & setup locales
RUN apt-get update && apt-get install -y \
    apt-utils \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    dirmngr \
    gdb \
    git \
    gnupg2 \
    keyboard-configuration \
    locales \
    lsb-release \
    python3-pip \
    software-properties-common \
    vim \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8; dpkg-reconfigure -f noninteractive locales

ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8"

# install hb dependecies packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    rsync \
    libglew-dev \
    libeigen3-dev \
    lua5.1 \
    liblua5.1-0 \
    liblua5.1-0-dev \
    nlohmann-json3-dev 

# install ROS2 packages & init rosdep
RUN apt-get update && apt-get install -y \
    ros-humble-rviz2 \
    ros-humble-xacro \
    ros-humble-cv-bridge \
    ros-humble-plotjuggler-ros \
    ros-humble-teleop-twist-joy \
    ros-humble-joint-state-publisher-gui \
    ros-humble-rqt \
    python3-autopep8 \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && /bin/bash -c 'source /opt/ros/humble/setup.bash'

# customize bash
COPY bashrc-git-prompt /tmp/
RUN curl -L https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh >> /etc/skel/.bashrc \
    && cat /tmp/bashrc-git-prompt >> /etc/skel/.bashrc \
    && rm -rf /tmp/bashrc-git-prompt \
    && echo "source /opt/ros/humble/setup.bash" >> /etc/skel/.bashrc \
    && echo "PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ '" >> /etc/skel/.bashrc

RUN curl -L -o libtorch.zip https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-2.1.0%2Bcpu.zip \
    && unzip libtorch.zip \
    && rm libtorch.zip \
    && mv libtorch /usr/local/lib/

ENV Torch_DIR=/usr/local/lib/libtorch
# install python packages
RUN python3 -m pip --no-cache-dir install \
    setuptools==58.2.0 

# set up entrypoint
COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint"]

CMD ["/bin/bash"]
LABEL maintainer="Maciej Krupka (krupka.maciej@icloud.com)"
