BASH_FILES := obon test/setup.sh test/test_helper/common.bash

BATS_LIB_PATH ?= $(CURDIR)/test/test_libs
export BATS_LIB_PATH

.PHONY: test lint fmt setup clean

setup:
	@mkdir -p test/test_libs
	@if [ ! -d test/test_libs/bats-support ]; then \
		git clone --depth 1 https://github.com/bats-core/bats-support.git test/test_libs/bats-support; \
	fi
	@if [ ! -d test/test_libs/bats-assert ]; then \
		git clone --depth 1 https://github.com/bats-core/bats-assert.git test/test_libs/bats-assert; \
	fi

test:
	bats test/

lint:
	shellcheck $(BASH_FILES)
	shfmt -d -i 2 -ci $(BASH_FILES)

fmt:
	shfmt -w -i 2 -ci $(BASH_FILES)

clean:
	-pkill -f "tmux.*-L obon-test" 2>/dev/null || true
