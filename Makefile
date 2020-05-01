SHELL := /usr/bin/env bash -euo pipefail -c

REPO  ?= av-scan-files
TAG   ?= latest
IMAGE ?= $(REPO):$(TAG)

build:
	docker build -t $(IMAGE) .

test: test-good test-bad
	@echo "==> OK: All tests passed."

# TEST is a macro that takes 3 arguments:
#
# 1: Scan Script
# 2: Target Dir
# 3: Expected Exit Code
define TEST
	@\
		echo "==> Running against internal test directory."; \
		docker run --rm $(IMAGE) $(1) $(2); \
		GOT=$$?; \
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
	$(call TEST,/scan-dir-maldet,/av-test/bad,1)
