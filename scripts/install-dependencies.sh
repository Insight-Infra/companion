#!/usr/bin/env bash

GIT_REPO=Insight-Infra/companion
GIT_BRANCH=RPi4_miniROV
GIT_TAG=0.1.1

. ./bash-helpers.sh

# Update package lists and current packages
run_step export DEBIAN_FRONTEND=noninteractive
APT_OPTIONS=-yq
run_step sudo apt update $APT_OPTIONS
run_step sudo apt upgrade $APT_OPTIONS

# install python and pip
run_step sudo apt install $APT_OPTIONS \
  python-dev \
  python-pip \
  python3-pip \
  python-libxml2 \
  python-lxml \
  libcurl4-openssl-dev \
  libxml2-dev \
  libxslt1-dev \
  libffi-dev \
  git \
  screen \
  npm \
  nodejs \
  gstreamer1.0-tools \
  gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-ugly \
  gstreamer1.0-plugins-base-apps \
  isc-dhcp-server \
  python3-pip \
  libv4l-dev \
  v4l-utils \
  libkrb5-dev \
  i2c-tools \
  socat \
  || error "failed apt install dependencies"

run_step sudo npm install npm@latest -g

# browser based terminal
#run_step sudo npm install tty.js -g || error "failed npm install dependencies"

run_step sudo pip install \
  future \
  pynmea2 \
  grequests \
  bluerobotics-ping \
  || error "failed pip install dependencies"

run_step sudo pip3 install \
  future \
  bluerobotics-ping \
  || error "failed pip3 install dependencies"

# todo adjust so this can be run when the directory already exists
# clone bluerobotics companion repository
run_step bash -c "git clone --depth 1 -b $GIT_BRANCH https://github.com/$GIT_REPO $COMPANION_DIR || echo 'git directory exists, skipping clone' "

ORIGINAL_DIR=$(pwd)

run_step cd $COMPANION_DIR

run_step git fetch --tags
run_step git reset --hard $GIT_TAG
run_step git clean -fd

run_step git submodule update --init --recursive
run_step cd $COMPANION_DIR/submodules/mavlink/pymavlink
run_step python3 setup.py build
run_step sudo python3 setup.py install

run_step cd $COMPANION_DIR/submodules/MAVProxy
run_step python setup.py build
run_step sudo python setup.py install

run_step cd $COMPANION_DIR/br-webui
run_step export JOBS=4
run_step npm install

run_step sudo python3 $HOME/companion/services/network/setup.py install
cd $ORIGINAL_DIR
