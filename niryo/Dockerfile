FROM wolfv/base_ros_docker:latest
# FROM ros:melodic-ros-base

RUN rosdep update

RUN sudo chown ${NB_USER}:${NB_USER} -R /home/${NB_USER}
RUN mkdir -p /home/${NB_USER}/catkin_ws/src
WORKDIR /home/${NB_USER}/catkin_ws

RUN cd src && git clone https://github.com/wolfv/niryo_one_ros
# RUN rosdep install --from-paths src --ignore-src -r -y

RUN sudo apt-get update && \
	sudo apt-get install -y python-pip \
					   ros-${ROS_DISTRO}-moveit \
					   ros-${ROS_DISTRO}-robot-state-publisher \
					   ros-${ROS_DISTRO}-rosbridge-suite \
					   ros-${ROS_DISTRO}-joy ros-${ROS_DISTRO}-ros-control \
					   ros-${ROS_DISTRO}-ros-controllers \
					   ros-${ROS_DISTRO}-tf2-web-republisher \
					   ros-${ROS_DISTRO}-joint-state-publisher

RUN bash -c "source /opt/ros/melodic/setup.bash && catkin build"

RUN sudo apt-get install python-jsonpickle

ADD ./niryo/kompose_interactive_markers ./src/kompose_interactive_markers
ADD ./helpers/server ./src/superserver

RUN bash -c "source devel/setup.bash \
       		 && catkin build"

COPY ./niryo/fake_with_web.launch /launchfiles/fake_with_web.launch

RUN sudo python3 -m pip install jupyterlab-zethus jupyterlab-webviz --upgrade

COPY ./niryo/start.sh /
RUN sudo chmod a+x /start.sh
CMD ["/bin/bash", "-c", "/start.sh && unset PYTHONPATH && jupyter lab --no-browser --ip=0.0.0.0 --NotebookApp.token=''"]
