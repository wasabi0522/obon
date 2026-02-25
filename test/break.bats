#!/usr/bin/env bats

setup() {
  load test_helper/common

  export OBON_TMUX_SOCKET="obon-test-$$-${BATS_TEST_NUMBER}"
  export OBON_TARGET_CMD="sleep"
  export OBON_MIN_PANE_WIDTH=10
  export OBON_SESSION="hs/org/repo"
  export TMUX="/tmp/tmux-test/default,12345,0"

  tmux -L "$OBON_TMUX_SOCKET" new-session -d -s "hs/org/repo" -n "hs/main" -x 200 -y 50
}

teardown() {
  tmux -L "$OBON_TMUX_SOCKET" kill-server 2>/dev/null || true
}

# --- Error cases ---

@test "break: does not require OBON_TARGET_CMD" {
  unset OBON_TARGET_CMD
  run "$OBON_BIN" break
  assert_failure
  assert_output --partial "no obon window found"
}

@test "break: fails when no obon window exists" {
  run "$OBON_BIN" break
  assert_failure
  assert_output --partial "no obon window found"
}

@test "break --all: fails when obon session does not exist" {
  run "$OBON_BIN" break --all
  assert_failure
  assert_output --partial "obon session does not exist"
}

@test "break: unknown option fails" {
  run "$OBON_BIN" break --bad
  assert_failure
  assert_output --partial "unknown option"
}

# --- Break default: round-trip test ---

@test "break: restores panes after join" {
  tmux -L "$OBON_TMUX_SOCKET" new-window -t "hs/org/repo" -n "hs/feature/x"
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/feature/x" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/feature/x" "sleep"

  # Join
  run "$OBON_BIN" join -y
  assert_success
  assert_output --partial "Joined 1 pane(s)"

  # Verify obon window exists
  run tmux -L "$OBON_TMUX_SOCKET" list-windows -t "hs/org/repo" -F '#{window_name}'
  assert_output --partial "obon"

  # Break
  run "$OBON_BIN" break
  assert_success
  assert_output --partial "Restored 1 pane(s)"

  # Verify obon window is gone (tmux auto-deletes empty windows) and original window restored
  run tmux -L "$OBON_TMUX_SOCKET" list-windows -t "hs/org/repo" -F '#{window_name}'
  refute_output --partial "obon"
  assert_output --partial "hs/feature/x"
}

# --- Break --all: round-trip test ---

@test "break --all: restores panes after join --all" {
  tmux -L "$OBON_TMUX_SOCKET" new-session -d -s "hs/org/other" -n "hs/main" -x 200 -y 50

  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/main" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/main" "sleep"
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/other:hs/main" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/other:hs/main" "sleep"

  # Join --all
  run "$OBON_BIN" join --all -y
  assert_success
  assert_output --partial "Joined 2 pane(s)"

  # Verify obon session exists
  run tmux -L "$OBON_TMUX_SOCKET" has-session -t "obon"
  assert_success

  # Break --all
  run "$OBON_BIN" break --all
  assert_success
  assert_output --partial "Restored 2 pane(s)"

  # Verify obon session is gone (tmux auto-deletes empty sessions)
  run tmux -L "$OBON_TMUX_SOCKET" has-session -t "obon"
  assert_failure
}
