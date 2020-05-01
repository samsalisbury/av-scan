SHELL := /usr/bin/env bash -euo pipefail -c

REPO  ?= av-scan-files
TAG   ?= latest
IMAGE ?= $(REPO):$(TAG)

build:
	docker build -t $(IMAGE) .

test:
	docker run $(IMAGE) "/var/log"
