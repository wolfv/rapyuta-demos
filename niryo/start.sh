sudo service ssh start 
sudo service nginx start

export HOME=/home/${NB_USER}

ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST="${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST:-localhost}"
ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT="${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT:-5555}"
WS_EP="ws://${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST}:${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT}/ros/bridge"

VNC_HOST="${VNC_HOST:-localhost}"
VNC_PORT="${VNC_PORT:-6901}"

mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-webviz/
mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-zethus/
mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-novnc/

printf '{"defaultROSEndpoint": "%s"}' "${WS_EP}" > \
	~/.jupyter/lab/user-settings/jupyterlab-webviz/plugin.jupyterlab-settings;

printf '{"defaultROSEndpoint": "%s"}' "${WS_EP}" > \
	~/.jupyter/lab/user-settings/jupyterlab-zethus/settings.jupyterlab-settings;
printf '{"configured_endpoints": [{"name": "Default", "autoconnect": true,"reconnect": true,"reconnect_delay": 1000, "host": "%s","port": "%s", "logging": "info","resize": "scale"}]}' "${VNC_HOST}" "${VNC_PORT}" > \
	~/.jupyter/lab/user-settings/jupyterlab-novnc/jupyterlab-novnc-settings.jupyterlab-settings;

source ~/catkin_ws/devel/setup.bash

roscore &
roslaunch --wait /launchfiles/fake_with_web.launch &
