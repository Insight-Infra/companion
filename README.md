# companion-miniROV

This repository is the Insight Infrastructure version of the [bluerobotics/companion](https://github.com/bluerobotics/companion) repository. This is the code that runs on the Raspberry Pi in the miniROV. Currently, this repository only provides an implementation for the Raspberry Pi Computer.

Includes
- modifications for top camera

## Install with

```shell
wget https://raw.githubusercontent.com/Insight-Infra/companion/RPi4_miniROV/scripts/install.sh
chmod +x install.sh
./install.sh
```

Then:
1. Use `gst-device-monitor-1.0` to inspect the available video devices
2. Find `caps : video/x-h264` and look at `properties : device.path = /dev/video??`
3. Add to `~/vidformat.param`
