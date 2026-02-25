OBON_BIN="$BATS_TEST_DIRNAME/../obon"

# Load bats libraries: local (test/test_libs/) or system (bats-action in CI)
if [[ -d "$BATS_TEST_DIRNAME/test_libs/bats-support" ]]; then
  load "$BATS_TEST_DIRNAME/test_libs/bats-support/load"
  load "$BATS_TEST_DIRNAME/test_libs/bats-assert/load"
else
  load "bats-support/load"
  load "bats-assert/load"
fi

# Wait until pane_current_command matches the expected command.
# Usage: wait_for_cmd <tmux_socket> <target> <expected_cmd> [timeout_secs]
wait_for_cmd() {
  local socket="$1" target="$2" expected="$3" timeout="${4:-5}"
  local deadline=$(( SECONDS + timeout ))
  local cmd
  while (( SECONDS < deadline )); do
    cmd=$(tmux -L "$socket" display-message -t "$target" -p '#{pane_current_command}' 2>/dev/null) || true
    [[ "$cmd" == "$expected" ]] && return 0
    sleep 0.1
  done
  echo "wait_for_cmd: timed out waiting for '$expected' in $target (got '$cmd')" >&2
  return 1
}
