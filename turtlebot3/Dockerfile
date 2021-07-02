FROM ros:melodic-ros-base

RUN rosdep update

RUN mkdir -p /catkin_ws/src
WORKDIR /catkin_ws

RUN apt-get update && apt-get install -y ros-${ROS_DISTRO}-turtlebot3

RUN cd src/ && git clone -b melodic-devel https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git
RUN apt-get install -y ros-${ROS_DISTRO}-gazebo-ros
RUN apt-get install -y ros-${ROS_DISTRO}-rosbridge-suite ros-${ROS_DISTRO}-tf2-web-republisher
RUN bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash \
       		 && catkin_make"
RUN mkdir -p /launchfiles
COPY fake_with_web.launch /launchfiles

RUN echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc

COPY helpers/cloudserver src/cloudserver
RUN bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash \
       		 && catkin_make"
