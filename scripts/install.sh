#!/usr/bin/env bash

export COMPANION_DIR=$HOME/companion

GIT_USER=Insight-Infra
GIT_BRANCH=RPi4_miniROV
BASE_URL=https://raw.githubusercontent.com/$GIT_USER/companion/$GIT_BRANCH/scripts

mkdir tmp || { echo "failed to make temporary directory" >&2 && exit 1; }
pushd tmp

wget $BASE_URL/bash-helpers.sh || { echo "failed to download $BASE_URL/bash-helpers.sh" >&2 && exit 1; }

# source helpers
. ./bash-helpers.sh

# get scripts
run_step wget $BASE_URL/install-dependencies.sh
run_step wget $BASE_URL/setup-system-files.sh
run_step wget $BASE_URL/setup-raspbian.sh

run_step chmod +x *.sh

# install dependencies from apt, pip etc
run_step ./install-dependencies.sh

# setup system and user configuration files
run_step ./setup-system-files.sh

# setup raspbian/raspberry-pi specific files
if grep -q 'Hardware.*: BCM2' /proc/cpuinfo; then
  run_step ./setup-raspbian.sh
fi

# clean up, remove files
popd
rm -rf tmp
