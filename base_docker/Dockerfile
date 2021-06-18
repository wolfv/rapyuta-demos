FROM ubuntu:18.04

################################## JUPYTERLAB ##################################

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8               \
    LANGUAGE=en_US.UTF-8           \
    SHELL=/bin/bash                \
	NB_USER=rapyuta                \
	NB_UID=1000

RUN echo "Acquire::ForceIPv4 'true';" > /etc/apt/apt.conf.d/99-force-ipv4

RUN apt-get update && apt-get -yq dist-upgrade  \
 && apt-get install -yq --no-install-recommends \
	locales cmake git build-essential sudo      \
    python-pip                                  \
	python3-pip python3-setuptools              \
 && apt-get clean                               \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools                 \
 && python3 -m pip install jupyterlab bash_kernel \
                           jupyterlab-novnc jupyterlab-zethus \
 && python3 -m bash_kernel.install

RUN adduser --disabled-password \
	--gecos "Default user" \
	--uid ${NB_UID} \
	${NB_USER} && usermod -aG sudo ${NB_USER}

ENV HOME=/home/${NB_USER}

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip=0.0.0.0", "--NotebookApp.token=''"]

##################################### COPY #####################################
## Add all install scripts for further steps

## Envrionment config

RUN printenv

ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    VNCPASSWD=vncpassword \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/home/${NB_USER}/install \
    NO_VNC_HOME=/home/${NB_USER}/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1920x1080 \
    VNC_PW=$VNCPASSWD \
    VNC_VIEW_ONLY=false

EXPOSE $VNC_PORT $NO_VNC_PORT

ADD ./base_docker/src/common/install/ ${INST_SCRIPTS}/
RUN find ${INST_SCRIPTS} -name '*.sh' -exec chmod a+x {} +

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    xvfb x11-utils openssh-server \
    vim wget net-tools locales bzip2 \
    python-numpy \
    supervisor xfce4 xfce4-terminal \
    pm-utils xscreensaver* \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-xorg-extension \
    dbus-x11 \
    x11-xserver-utils \
    xubuntu-icon-theme \
    gnome-icon-theme \
    locales-all locales \
    tango-icon-theme \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

## Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN ${INST_SCRIPTS}/no_vnc.sh

ADD ./base_docker/src/common/xfce/ /home/${NB_USER}/

## configure startup
RUN echo "Install nss-wrapper to be able to execute image as non-root user" && \
    apt-get update && apt-get install -yq --no-install-recommends libnss-wrapper gettext \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# have to be added to hold all env vars correctly
RUN echo "add 'souce generate_container_user' to .bashrc" && \
    echo 'source $STARTUPDIR/generate_container_user' >> /home/${NB_USER}/.bashrc

ADD ./base_docker/src/common/scripts $STARTUPDIR
RUN ${INST_SCRIPTS}/set_user_permission.sh $STARTUPDIR $HOME

RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN echo 'export NOTVISIBLE="in users profile"' >> /home/${NB_USER}/.bashrc
RUN echo "export VISIBLE=now" >> /etc/profile

###################################### ROS #####################################

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

# install ros packages
ENV ROS_DISTRO melodic
RUN apt-get update && apt-get install -yq  --no-install-recommends \
    python-rosdep \
    python-rosinstall \
    python-vcstools \
    python-catkin-tools \
    ros-${ROS_DISTRO}-ros-base \
    git \
    python-pip \
    python-dev \
    libgtk2.0-0 \
    unzip \
    libblas-dev \
    liblapack-dev \
    libhdf5-dev \
    ipython \
    python-rospkg \
    nginx \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init && rosdep update

RUN mkdir -p /home/${NB_USER}/.ros
RUN chown -R ${NB_USER}:${NB_USER} /home/${NB_USER}

################################### CUSTOM #####################################

RUN python2 -m pip install wheel ipykernel rospkg
RUN python2 -m ipykernel install --user

ADD ./base_docker/nginx.conf /etc/nginx/nginx.conf
ADD ./base_docker/site.conf /etc/nginx/conf.d/default.conf
RUN chmod -R g+w /var/log/nginx 

ADD ./base_docker/html /usr/share/nginx/html

##################################### TAIL #####################################
# setup entrypoint
RUN mkdir -p /home/${NB_USER}/js_templates
COPY --chown=1000:1000 ./base_docker/html/env.template.js /home/${NB_USER}/js_templates/env.template.js

COPY ./base_docker/ros_entrypoint.sh /
RUN chmod a+x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]

RUN chown ${NB_UID} /home/${NB_USER}/js_templates
RUN chown -R ${NB_USER} /home/${NB_USER}
RUN echo "root:toor" | chpasswd
RUN echo "${NB_USER}:robotics" | chpasswd


COPY ./base_docker/start.sh /
COPY ./base_docker/run-turtle.sh /home/${NB_USER}/catkin_ws/
RUN chmod a+x /start.sh
RUN chmod a+x /home/${NB_USER}/catkin_ws/run-turtle.sh

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> \
/etc/sudoers

USER ${NB_USER}
ENV WS_ENV_PORT=9090
RUN echo "export TURTLEBOT3_MODEL=burger" >> ~/.bashrc
RUN echo "export PYTHONPATH=$PYTHONPATH:/usr/lib/python2.7/dist-packages" >> ~/.bashrc
RUN echo "source ~/catkin_ws/devel/setup.bash" >> /home/${NB_USER}/.bashrc

EXPOSE 6901
EXPOSE 22
EXPOSE 8080
EXPOSE 9090

WORKDIR /home/${NB_USER}/catkin_ws
CMD ["bash", "-c", "/start.sh && ./run-turtle.sh  &&  jupyter lab --no-browser --ip=0.0.0.0 --NotebookApp.token=''"]

# RUN mkdir -p /home/rapyuta/.ros
# RUN chown rapyuta.rapyuta /home/rapyuta/.ros
# 
# RUN mkdir -p ${HOME}/catkin_ws/src && cd ${HOME}/catkin_ws/src && git clone https://github.com/rapyuta-robotics/io_tutorials.git
# 
# RUN  cd ${HOME}/catkin_ws \
#  && apt-get update \
#  && /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && rosdep update && rosdep install --as-root apt:false --from-paths src --ignore-src -r -y" \
#  && apt-get install -yq --no-install-recommends \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/* \
#  && /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && catkin build"

# WORKDIR  ${HOME}/catkin_ws/src/io_tutorials/io_turtlesim/io_turtlesim_webserver/ 
# RUN cp ./env.sh /usr/bin/
