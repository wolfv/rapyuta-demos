sudo service ssh start 
sudo service nginx start

ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST="${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST:-localhost}"
ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT="${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT:-5555}"
WS_EP="ws://${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST}:${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT}/ros/bridge"

echo '{"defaultROSEndpoint": "${WS_EP}"}' > \
	/home/${NB_USER}/.jupyter/lab/user-settings/jupyterlab-webviz/plugin.jupyterlab-settings;
echo '{"defaultROSEndpoint": "${WS_EP}"}' > \
	/home/${NB_USER}/.jupyter/lab/user-settings/jupyterlab-zethus/settings.jupyterlab-settings;

source ~/catkin_ws/devel/setup.bash

roscore &
roslaunch --wait /launchfiles/fake_with_web.launch &
