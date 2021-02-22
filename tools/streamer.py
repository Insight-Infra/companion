#!/usr/bin/python

import os
from time import sleep
import sys
script = os.environ['HOME'] + "/companion/scripts/start_video.sh"

os.system("sudo modprobe bcm2835-v4l2")

while True:
  while (os.system("ls /dev/video* 2>/dev/null") != 0) or not os.path.isfile(script):
    sleep(5) # wait for video to exist

  if len(sys.argv) == 1:
    os.system(script + " $(cat /home/pi/vidformat.param)")
  else:
    os.system(script + " ".join(sys.argv[1:]))
  sleep(2)


