NUM_CPUS = $(shell nproc ||  grep -c '^processor' /proc/cpuinfo)
SETUP_PY_FLAGS = --use-distutils

UNAME_S := $(shell uname -s)
DOCKER_FLAGS := --rm
ifeq ($(UNAME_S),Linux)
	DOCKER_FLAGS = --rm \
		--net=host \
		--env="DISPLAY" \
		-v /var/run/dbus:/var/run/dbus \
		--privileged \
		--volume="${HOME}/.Xauthority:/root/.Xauthority:rw" \
		-e NO_AT_BRIDGE=1 \
		--ipc=host \
		--user="$(id --user):$(id --group)"
endif

all: build FORCE

build: FORCE
	python setup.py build -j$(NUM_CPUS) $(SETUP_PY_FLAGS)

clean: FORCE
	-rm -rf build

dist:
	util/sdist.sh

distclean: clean FORCE
	-rm -f INSTALLED_FILES
	-rm -f setuptools-*.egg
	-rm -f use-distutils

html:
	./setup.py readme

install: build FORCE
	python setup.py install $(SETUP_PY_FLAGS)

requirements: requirements.txt requirements-dev.txt
	pip install wheel pip --upgrade
	MAKEFLAGS="-j$(NUM_CPUS)" pip install  -r requirements.txt
	MAKEFLAGS="-j$(NUM_CPUS)" pip install  -r requirements-dev.txt

uninstall:
	./setup.py uninstall $(SETUP_PY_FLAGS)

docker-build:
	docker build -t displaycal-py3 .

docker-build-clean:
	docker build --no-cache -t displaycal-py3 .

# TODO: If we have more than 1 image, move to docker-compose
docker-run:
	docker run $(DOCKER_FLAGS) displaycal-py3

docker-sh:
	docker run $(DOCKER_FLAGS) -it displaycal-py3 /bin/bash

x11-test:
	docker build -t x11-apps -f Dockerfile.x11_test .
	docker run -it $(DOCKER_FLAGS) x11-apps /bin/bash # xeyes

# https://www.gnu.org/software/make/manual/html_node/Force-Targets.html
FORCE:
