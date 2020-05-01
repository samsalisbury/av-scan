SHELL := /usr/bin/env bash -euo pipefail -c

REPO  ?= av-scan
TAG   ?= latest
IMAGE ?= $(REPO):$(TAG)
SCAN_DIR ?= $(CURDIR)

build:
	docker build -t $(IMAGE) .

test: test-good test-bad
	@echo "==> OK: All tests passed."

scan: build
	@\
		if [ $(SCAN_DIR) = $(CURDIR) ]; then \
			echo "==> WARNING: Scanning current directory which contains Malware test string in install script!"; \
		fi; \
		echo "==> Mounting $(SCAN_DIR) to /files-to-scan inside the container..."; \
		docker run --rm -v $(SCAN_DIR):/files-to-scan $(IMAGE) "/scan-dir /files-to-scan"

# TEST is a macro that takes 3 arguments:
#
# 1: Scan Script
# 2: Target Dir
# 3: Expected Exit Code
define TEST
	@\
		echo "==> Running against internal test directory."; \
		set +e; \
		docker run --rm $(IMAGE) $(1) $(2); \
		GOT=$$?; \
		set -e; \
		if [[ $$GOT != $(3) ]]; then \
			echo "ERROR: got $(1) $(2) == exit code $$GOT; want $(3)"; \
			exit 1; \
		fi; \
		echo "==> OK: $(1) $(2) == exit code $$GOT"
endef

test-good: test-good-clamav test-good-maldet
	$(call TEST,/scan-dir,/av-test/good,0)

test-bad: test-bad-clamav test-bad-maldet
	$(call TEST,/scan-dir,/av-test/bad,1)

test-good-clamav:
	$(call TEST,/scan-dir-clamav,/av-test/good,0)

test-bad-clamav:
	$(call TEST,/scan-dir-clamav,/av-test/bad,1)

test-good-maldet:
	$(call TEST,/scan-dir-maldet,/av-test/good,0)

test-bad-maldet:
	$(call TEST,/scan-dir-maldet,/av-test/bad,2)
