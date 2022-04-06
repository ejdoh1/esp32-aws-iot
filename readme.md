# ESP32 with AWS IoT Sample

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

# Cleanup cloud resources
make destroy
```
