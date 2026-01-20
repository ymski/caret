ARG ROS_DISTRO=humble
FROM ros:${ROS_DISTRO}

ARG CARET_VERSION="main"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        locales \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TZ=Asia/Tokyo
ENV ROS_DISTRO=humble

# Do not use cache
ADD "https://www.random.org/sequences/?min=1&max=52&col=1&format=plain&rnd=new" /dev/null

COPY ./ /ros2_caret_ws


RUN if [ "$ROS_DISTRO" = "jazzy" ]; then \
      apt-get update && \
      apt-get install -y python3-pip python3-virtualenv && \
      virtualenv -p python3 --system-site-packages $HOME/venv/jazzy ; \
    fi

# cspell: disable
RUN apt update && apt install -y git && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata
# cspell: enable

RUN echo "===== Setup CARET ====="
RUN cd ros2_caret_ws && \
    mkdir src && \
    vcs import src < caret.repos && \
    . /opt/ros/"$ROS_DISTRO"/setup.sh && \
    ./setup_caret.sh -c

RUN echo "===== Build CARET ====="
RUN cd ros2_caret_ws && \
    . /opt/ros/"$ROS_DISTRO"/setup.sh && \
    colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF

