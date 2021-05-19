FROM ros:kinetic-ros-base

RUN rosdep update

RUN mkdir -p /catkin_ws/src
WORKDIR /catkin_ws

RUN cd src && git clone https://github.com/wolfv/niryo_one_ros
RUN apt-get update
RUN apt-get install python-pip -y
RUN rosdep install --from-paths src --ignore-src -r -y

RUN apt-get install ros-${ROS_DISTRO}-moveit -y

RUN apt-get install -y ros-${ROS_DISTRO}-robot-state-publisher \
					   ros-${ROS_DISTRO}-rosbridge-suite \
					   ros-${ROS_DISTRO}-joy ros-${ROS_DISTRO}-ros-control \
					   ros-${ROS_DISTRO}-ros-controllers \
					   ros-${ROS_DISTRO}-tf2-web-republisher

RUN apt-get install -y ros-${ROS_DISTRO}-joint-state-publisher

RUN bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash \
       		 && catkin_make"
