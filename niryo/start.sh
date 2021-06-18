sudo service ssh start 
sudo service nginx start

export HOME=/home/${NB_USER}

ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST="${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST:-localhost}"
ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT="${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT:-5555}"
WS_EP="ws://${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST}:${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT}/ros/bridge"

VNC_HOST="${VNC_HOST:-localhost}"
VNC_HOST="${VNC_PORT:-6901}"

mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-webviz/
mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-zethus/
mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-novnc/

echo '{"defaultROSEndpoint": "${WS_EP}"}' > \
	~/.jupyter/lab/user-settings/jupyterlab-webviz/plugin.jupyterlab-settings;
echo '{"defaultROSEndpoint": "${WS_EP}"}' > \
	~/.jupyter/lab/user-settings/jupyterlab-zethus/settings.jupyterlab-settings;
echo '{"configured_endpoints": [{"name": "Default", "autoconnect": true,"reconnect": true,"reconnect_delay": 1000, "host": "${VNC_HOST}","port": ${VNC_PORT}, "logging": "info","resize": "scale"}]}' > \
	~/.jupyter/lab/user-settings/jupyterlab-novnc/jupyterlab-novnc-settings.jupyterlab-settings;

source ~/catkin_ws/devel/setup.bash

roscore &
roslaunch --wait /launchfiles/fake_with_web.launch &
