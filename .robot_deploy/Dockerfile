FROM ros:humble-ros-base
# Environment variables
ARG USER
ARG WORKSPACE
ENV USER=${USER} \
    UID=1000 \
    GID=1000 \
    WORKSPACE=${WORKSPACE} \
    AMENT_CPPCHECK_ALLOW_SLOW_VERSIONS=1 \
    AMENT_PREFIX_PATH=/opt/ros/humble \
    COLCON_PREFIX_PATH=/opt/ros/humble \
    DEBIAN_FRONTEND=noninteractive \
    LD_LIBRARY_PATH=/opt/ros/humble/lib \
    PATH=/opt/ros/humble/bin:$PATH \
    PYTHONPATH=/opt/ros/humble/lib/python3.10/site-packages:/opt/ros/humble/local/lib/python3.10/dist-packages \
    QT_X11_NO_MITSHM=1 \
    ROS_DISTRO=humble \
    ROS_PYTHON_VERSION=3 \
    ROS_VERSION=2 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

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
    nano \
    wget \
    locales \ 
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8; dpkg-reconfigure -f noninteractive locales


# customize bash
COPY bashrc-git-prompt /tmp/
RUN curl -L https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh >> /etc/skel/.bashrc \
    && cat /tmp/bashrc-git-prompt >> /etc/skel/.bashrc \
    && rm -rf /tmp/bashrc-git-prompt \
    && echo "source /opt/ros/humble/setup.bash" >> /etc/skel/.bashrc \
    && echo "PS1='\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ '" >> /etc/skel/.bashrc

# install python packages
COPY requirements.txt /tmp/
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm -rf /tmp/requirements.txt

# install your custom packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    rsync \
    libglew-dev \
    libeigen3-dev \
    lua5.1 \
    liblua5.1-0 \
    liblua5.1-0-dev \
    nlohmann-json3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# set up entrypoint
COPY entrypoint /entrypoint
ENTRYPOINT ["/entrypoint"]
RUN groupadd -g $GID -o $USER \
    && useradd -m -u $UID -g $GID -o -s /bin/bash $USER
USER $USER

RUN mkdir -p /home/$USER/$WORKSPACE

WORKDIR /home/$USER/$WORKSPACE

CMD ["/bin/bash"]
LABEL maintainer="Maciej Krupka (maciej.krupka@gmail.com)"
