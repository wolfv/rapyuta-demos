FROM ros:melodic-ros-base

RUN rosdep update

RUN mkdir -p /catkin_ws/src
WORKDIR /catkin_ws

RUN apt-get update && apt-get install -y ros-${ROS_DISTRO}-turtlebot3

RUN cd src/ && git clone -b melodic-devel https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
RUN apt-get install -y ros-${ROS_DISTRO}-gazebo-ros
RUN bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash \
       		 && catkin_make"
