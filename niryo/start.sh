sudo service ssh start 
sudo service nginx start

source ~/catkin_ws/devel/setup.bash
roscore &
roslaunch --wait /launchfiles/fake_with_web.launch &
