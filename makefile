include env.list
IMAGE ?= ejdoh1/awstfclient:1649215673
RUN ?= docker run -it --rm --volume $$(pwd):/work --env-file env.list ${IMAGE} bash -c "source ${ENV_SH} && 
ENV_SH ?= /work/scripts/env.sh
PORT ?= /dev/cu.SLAB_USBtoUART
FIRMWARE ?= esp32-20220117-v1.18.bin
AMPY ?= ampy -d 1 -p ${PORT} -b 115200

push-image: build-image
	d=$$(date +%s); \
	docker tag awstfclient:latest ejdoh1/awstfclient:$$d; \
	docker push ejdoh1/awstfclient:$$d

build-image:
	cd docker-image && docker build . -t awstfclient:latest

tf-init:
	${RUN} terraform -chdir=terraform init"

go: deploy deploy-esp32

deploy: tf-init deploy-aws-iot certs

deploy-aws-iot: tf-init
	${RUN} terraform -chdir=terraform apply -auto-approve"

deploy-esp32: flash-esp32 files copy-files reset-esp32

destroy: tf-init
	${RUN} terraform -chdir=terraform apply -destroy -auto-approve"

certs: get-cert-pem get-private-key

get-cert-pem: tf-init
	${RUN} terraform -chdir=terraform output -raw awsiot_cert_pem" > esp32/cert.pem

get-private-key: tf-init
	${RUN} terraform -chdir=terraform output -raw awsiot_private_key" > esp32/private.key

init-esp32:
	@ls /dev/cu.SLAB_USBtoUART || (echo "ESP32 not found. Is it plugged in?" && exit 1)

erase-esp32: init-esp32
	# Hold the boot button if the fails to connect
	esptool.py --port ${PORT} erase_flash

flash-esp32: init-esp32
	esptool.py --chip esp32 --port ${PORT} write_flash -z 0x1000 ${FIRMWARE}

copy-files: init-esp32
	${AMPY} put esp32/cert.pem
	${AMPY} put esp32/private.key
	${AMPY} put esp32/boot.py
	${AMPY} put esp32/main.py

files:
	export ENDPOINT=`${RUN} terraform -chdir=terraform output -raw awsiot_endpoint"`; \
	envsubst < esp32/main.template.py > esp32/main.py

	set -a; source env.list; set +a; \
	envsubst < esp32/boot.template.py > esp32/boot.py

list-files: init-esp32
	${AMPY} ls

reset-esp32:
	${AMPY} reset

sub:
	@awsiot_endpoint=`${RUN} terraform -chdir=terraform output -raw awsiot_endpoint"`; \
	mosquitto_sub -t "#" --cert esp32/cert.pem --key esp32/private.key -h $$awsiot_endpoint -p 8883 --cafile ca.pem -C 1

pub:
	@awsiot_endpoint=`${RUN} terraform -chdir=terraform output -raw awsiot_endpoint"`; \
	mosquitto_pub -t hello --cert esp32/cert.pem --key esp32/private.key -h $$awsiot_endpoint -m "Hello from PC" -p 8883 --cafile ca.pem
