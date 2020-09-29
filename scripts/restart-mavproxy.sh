#!/bin/bash

screen -X -S thickness quit
screen -X -S mavproxy quit

sudo -H -u pi screen -dm -S thickness $COMPANION_DIR/tools/ut_read.py &
sudo -H -u pi screen -dm -S mavproxy $COMPANION_DIR/tools/telem.py
