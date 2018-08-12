#
# Simple Makefile to help maintain the Docker image
#
IMAGE_NAME = demophp5
BASE_IMAGES = golang php:5-apache
TEST_IMAGES =
DOCKER_SOCKET = /var/run/docker.sock
DOCKER = docker
BUILD_ARGS = --rm

all: pull build check 

pull:
	##
	## Pulling image updates from registry
	##
	for IMAGE in ${BASE_IMAGES} ${TEST_IMAGES}; do \
		${DOCKER} pull $${IMAGE}; \
	done

build:
	##
	## Starting build of image ${IMAGE_NAME}
	##
	${DOCKER} build ${BUILD_ARGS} --tag ${IMAGE_NAME} .

check:
	@echo 'Currently there is no test suite.'
	#${DOCKER} run --rm -i -v ${DOCKER_SOCKET}:/var/run/docker.sock -v ${PWD}/:/mnt/ -e IMAGE_NAME=${IMAGE_NAME} ${TPACK_IMAGE}

clean:
	##
	## Removing docker images .. most errors during this stage are ok, ignore them
	##
	for IMAGE in ${BASE_IMAGES} ${TEST_IMAGES}; \
		do docker rmi $${IMAGE}; \
	done

.PHONY: all pull build check clean

