sudo service ssh start 
sudo service nginx start

export HOME=/home/${NB_USER}

ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST="${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST:-localhost}"
ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT="${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT:-5555}"

if [[ "$ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT" == "443" ]]; then
	WS_EP="wss://${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST}:${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT}/ros/bridge"
	PKGS_EP="https://${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST}:${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT}/ros/pkgs"
else
	WS_EP="ws://${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST}:${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT}/ros/bridge"
	PKGS_EP="http://${ROSBRIDGE_WEBSOCKET_ENDPOINT_HOST}:${ROSBRIDGE_WEBSOCKET_ENDPOINT_PORT}/ros/pkgs"
fi

VNC_EXTERNAL_HOST="${VNC_EXTERNAL_HOST:-localhost}"
VNC_EXTERNAL_PORT="${VNC_EXTERNAL_PORT:-6901}"

mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-webviz/
mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-zethus/
mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-novnc/

printf '{"defaultROSEndpoint": "%s"}' "${WS_EP}" > \
	~/.jupyter/lab/user-settings/jupyterlab-webviz/plugin.jupyterlab-settings;

printf '{"defaultROSEndpoint": "%s", "defaultROSPKGSEndpoint": "%s"}' "${WS_EP}" "${PKGS_EP}" > \
	~/.jupyter/lab/user-settings/jupyterlab-zethus/settings.jupyterlab-settings;

printf '{"configured_endpoints": [{"name": "Default", "autoconnect": true,"reconnect": true,"reconnect_delay": 1000, "host": "%s","port": "%s", "logging": "info","resize": "scale"}]}' "${VNC_EXTERNAL_HOST}" "${VNC_EXTERNAL_PORT}" > \
	~/.jupyter/lab/user-settings/jupyterlab-novnc/jupyterlab-novnc-settings.jupyterlab-settings;

source ~/catkin_ws/devel/setup.bash

ARG1="${1:-FAKE}"

if [[ $ARG1 == "FAKE" ]]; then
	roscore &
	roslaunch --wait /launchfiles/fake_with_web.launch &
else
	roscore &
	roslaunch --wait /launchfiles/real_with_web.launch &
fi

PYTHONPATH="" jupyter lab --no-browser --ip=0.0.0.0 --NotebookApp.token=''