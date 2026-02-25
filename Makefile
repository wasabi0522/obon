.PHONY: test lint fmt setup clean

setup:
	test/setup.sh

test: setup
	test/test_libs/bats-core/bin/bats test/

lint:
	shellcheck obon
	shfmt -d -i 2 -ci obon

fmt:
	shfmt -w -i 2 -ci obon

clean:
	-pkill -f "tmux.*-L obon-test" 2>/dev/null || true
