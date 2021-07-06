sudo service ssh start 
sudo service nginx start

export HOME=/home/${NB_USER}

python3 /home/${NB_USER}/install/kernel_generator.py python2 /home/${NB_USER}/catkin_ws/devel/setup.bash

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
mkdir -p ~/.jupyter/lab/user-settings/jupyterlab-jitsi/

printf '{"defaultROSEndpoint": "%s"}' "${WS_EP}" > \
	~/.jupyter/lab/user-settings/jupyterlab-webviz/plugin.jupyterlab-settings;

printf '{"defaultROSEndpoint": "%s", "defaultROSPKGSEndpoint": "%s"}' "${WS_EP}" "${PKGS_EP}" > \
	~/.jupyter/lab/user-settings/jupyterlab-zethus/plugin.jupyterlab-settings;

printf '{"configured_endpoints": [{"name": "Default", "autoconnect": true,"reconnect": true,"reconnect_delay": 1000, "host": "%s","port": "%s", "logging": "info","resize": "scale"}]}' "${VNC_EXTERNAL_HOST}" "${VNC_EXTERNAL_PORT}" > \
	~/.jupyter/lab/user-settings/jupyterlab-novnc/plugin.jupyterlab-settings;

cat > ~/.jupyter/lab/user-settings/jupyterlab-jitsi/plugin.jupyterlab-settings << EOM
{
  "configured_rooms": [{
    "domain": "meet.jit.si",
    "options": {
      "roomAlias": "Robot",
      "roomName": "thisisarapyutarobot",
      "configOverwrite": {
        "enableWelcomePage": false,
        "disableShortcuts": true,
        "disableInitialGUM": true,
        "enableClosePage": false,
        "disableProfile": true,
        "prejoinPageEnabled": false,
        "startWithAudioMuted": true,
        "toolbarButtons": [],
        "disableJoinLeaveSounds": true,
        "disableInviteFunctions": true
      },
      "interfaceConfigOverwrite": {
        "MOBILE_APP_PROMO": false,
        "SHOW_CHROME_EXTENSION_BANNER": false
      }
    }
  }]
}
EOM

source ~/catkin_ws/devel/setup.bash

ARG1="${1:-FAKE}"

cp /content/* ./

if [[ $ARG1 == "FAKE" ]]; then
	roscore &
	roslaunch --wait /launchfiles/fake_with_web.launch &
else
	roscore &
	roslaunch --wait /launchfiles/real_with_web.launch &
fi

PYTHONPATH="" jupyter lab --no-browser --ip=0.0.0.0 --NotebookApp.token=''