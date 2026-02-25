BASH_FILES := obon test/setup.sh test/test_helper/common.bash

.PHONY: test lint fmt setup clean

setup:
	test/setup.sh

test: setup
	test/test_libs/bats-core/bin/bats test/

lint:
	shellcheck $(BASH_FILES)
	shfmt -d -i 2 -ci $(BASH_FILES)

fmt:
	shfmt -w -i 2 -ci $(BASH_FILES)

clean:
	-pkill -f "tmux.*-L obon-test" 2>/dev/null || true
