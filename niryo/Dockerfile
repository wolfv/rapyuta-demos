FROM wolfv/base_ros_docker:latest

RUN rosdep update

RUN sudo chown ${NB_USER}:${NB_USER} -R /home/${NB_USER}
RUN mkdir -p /home/${NB_USER}/catkin_ws/src
WORKDIR /home/${NB_USER}/catkin_ws

RUN cd src && git clone https://github.com/wolfv/niryo_one_ros
# RUN rosdep install --from-paths src --ignore-src -r -y

RUN sudo apt-get update && \
    sudo apt-get install -y python-pip \
                       python-jsonpickle \
                       ros-${ROS_DISTRO}-moveit \
                       ros-${ROS_DISTRO}-robot-state-publisher \
                       ros-${ROS_DISTRO}-rosbridge-suite \
                       ros-${ROS_DISTRO}-joy ros-${ROS_DISTRO}-ros-control \
                       ros-${ROS_DISTRO}-ros-controllers \
                       ros-${ROS_DISTRO}-tf2-web-republisher \
                       ros-${ROS_DISTRO}-joint-state-publisher \
                       ros-${ROS_DISTRO}-web-video-server \
                && sudo apt-get clean \
                && sudo rm -rf /var/lib/apt/lists/*

ADD ./niryo/kompose_interactive_markers ./src/kompose_interactive_markers
ADD ./helpers/server ./src/superserver

RUN bash -c "source /opt/ros/melodic/setup.bash && catkin build"

RUN sudo python3 -m pip install jupyterlab-zethus jupyterlab-webviz --upgrade

COPY ./niryo/fake_with_web.launch /launchfiles/fake_with_web.launch
COPY ./niryo/real_with_web.launch /launchfiles/real_with_web.launch
COPY ./niryo/start.sh /launchfiles/
COPY ./helpers/kernel_generator.py ./kernel_generator.py

RUN python3 kernel_generator.py python2 ./devel/setup.bash

RUN sudo chmod a+x /launchfiles/start.sh

CMD ["/bin/bash", "-c", "/launchfiles/start.sh FAKE"]
