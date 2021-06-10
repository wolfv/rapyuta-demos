#!/bin/bash
source devel/setup.bash
envsubst < /home/js_templates/env.template.js > /home/js_templates/env.js
sudo cp -rf /home/js_templates/env.js /usr/share/nginx/html/env.js

roscore & 
roslaunch --wait io_turtle_sim_env simulation.launch &
roslaunch --wait io_turtle_command_center command_center.launch websocket_external_port:=`echo ${WS_ENV_PORT}` &
roslaunch --wait io_turtle turtle.launch &
