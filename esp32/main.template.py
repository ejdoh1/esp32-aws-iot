import sys
import machine
from umqtt.simple import MQTTClient
import utime

ENDPOINT = "$ENDPOINT"
CLIENT_ID = "esp32"
TOPIC = "esp32topic"
MESSAGE = "from esp32 counter "

led = machine.Pin(2, machine.Pin.OUT)
led.value(0)

with open('private.key') as f:
    key_data = f.read()

with open('cert.pem') as f:
    cert_data = f.read()


def sub_cb(topic, msg):
    print(msg)
    led.value(1)


c = MQTTClient(
    CLIENT_ID,
    ENDPOINT,
    ssl=True,
    ssl_params={
        'key': key_data,
        'cert': cert_data
    })

c.set_callback(sub_cb)
c.connect()
print('connected')
c.subscribe(TOPIC)
print('subscribed to ' + TOPIC)

counter = 0
while True:
    counter = counter + 1
    utime.sleep_ms(100)
    c.check_msg()
    if counter % 10 == 0:
        print('publishing')
        c.publish(TOPIC, MESSAGE + str(counter), qos=1)
        print('published')
        led.value(0)
    if counter == 100:
        print('exiting')
        sys.exit(0)
