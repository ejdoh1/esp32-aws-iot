# ESP32 with AWS IoT Sample

## Prerequisites

- [Adafruit MicroPython tool (ampy)](https://learn.adafruit.com/micropython-basics-load-files-and-run-code/install-ampy)
- [esptool.py](https://github.com/espressif/esptool)
- Docker, installed and running

```sh
export AWS_ACCESS_KEY_ID=REPLACE_ME
export AWS_SECRET_ACCESS_KEY=REPLACE_ME
export WIRELESS_NETWORK_NAME=REPLACE_ME
export WIRELESS_NETWORK_PASSWORD=REPLACE_ME

envsubst < env.list.template > env.list

# Hold boot button during erase. Release when done
make erase-esp32

# Deploy cloud resources & ESP32 code
make go

# The blue ESP32 LED will flash multiple times - it is working!

# Cleanup cloud resources
make destroy
```
