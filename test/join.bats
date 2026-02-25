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

@test "join: fails without OBON_TARGET_CMD" {
  unset OBON_TARGET_CMD
  run "$OBON_BIN" join
  assert_failure
  assert_output --partial "OBON_TARGET_CMD is not set"
}

@test "join: fails outside tmux" {
  unset TMUX
  unset OBON_SESSION
  run "$OBON_BIN" join
  assert_failure
  assert_output --partial "not inside a tmux session"
}

@test "join: shows message when no target panes found" {
  run "$OBON_BIN" join -y
  assert_success
  assert_output --partial "No target panes found"
}

@test "join: no target panes when obon window already exists" {
  tmux -L "$OBON_TMUX_SOCKET" new-window -t "hs/org/repo" -n "obon"
  run "$OBON_BIN" join -y
  assert_success
  assert_output --partial "No target panes found"
}

@test "join: unknown option fails" {
  run "$OBON_BIN" join --bad
  assert_failure
  assert_output --partial "unknown option"
}

# --- Join default: functional tests ---

@test "join: aggregates target panes into obon window" {
  tmux -L "$OBON_TMUX_SOCKET" new-window -t "hs/org/repo" -n "hs/feature/a"
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/feature/a" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/feature/a" "sleep"

  tmux -L "$OBON_TMUX_SOCKET" new-window -t "hs/org/repo" -n "hs/feature/b"
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/feature/b" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/feature/b" "sleep"

  run "$OBON_BIN" join -y
  assert_success
  assert_output --partial "Joined 2 pane(s) into obon window"

  run tmux -L "$OBON_TMUX_SOCKET" list-windows -t "hs/org/repo" -F '#{window_name}'
  assert_output --partial "obon"
}

@test "join: pane titles are set correctly" {
  tmux -L "$OBON_TMUX_SOCKET" new-window -t "hs/org/repo" -n "hs/develop"
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/develop" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/develop" "sleep"

  run "$OBON_BIN" join -y
  assert_success
  assert_output --partial "Joined 1 pane(s)"

  run tmux -L "$OBON_TMUX_SOCKET" list-panes -t "hs/org/repo:obon" -F '#{pane_title}'
  assert_output --partial "develop"
}

@test "join: detects pane when target command has spawned a subprocess" {
  export OBON_TARGET_CMD="bash"

  # Occupy hs/main so its pane_current_command is not "bash"
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/main" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/main" "sleep"

  tmux -L "$OBON_TMUX_SOCKET" new-window -t "hs/org/repo" -n "hs/feature/sub"
  # bash -m enables job control: sleep gets its own foreground process group,
  # so pane_current_command becomes "sleep" while bash remains as parent.
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/feature/sub" \
    "bash -m -c 'trap : INT; sleep 600'" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/feature/sub" "sleep"

  run "$OBON_BIN" join -y
  assert_success
  assert_output --partial "Joined 1 pane(s) into obon window"
}

@test "join: selects pane with lowest index when multiple match" {
  tmux -L "$OBON_TMUX_SOCKET" new-window -t "hs/org/repo" -n "hs/multi"
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/multi" "sleep 600" Enter
  tmux -L "$OBON_TMUX_SOCKET" split-window -t "hs/org/repo:hs/multi" -h
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/multi" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/multi.0" "sleep"
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/multi.1" "sleep"

  run "$OBON_BIN" join -y
  assert_success
  assert_output --partial "Joined 1 pane(s) into obon window"
}

# --- Join --all: error cases ---

@test "join --all: fails outside tmux" {
  unset TMUX
  unset OBON_SESSION
  run "$OBON_BIN" join --all
  assert_failure
  assert_output --partial "not inside a tmux session"
}

@test "join --all: no target panes when obon session already exists" {
  tmux -L "$OBON_TMUX_SOCKET" new-session -d -s "obon" -n "obon"
  run "$OBON_BIN" join --all -y
  assert_success
  assert_output --partial "No target panes found"
}

@test "join --all: shows message when no target panes found" {
  run "$OBON_BIN" join --all -y
  assert_success
  assert_output --partial "No target panes found"
}

# --- Join --all: functional test ---

@test "join --all: aggregates panes across sessions into obon session" {
  tmux -L "$OBON_TMUX_SOCKET" new-session -d -s "hs/org/other" -n "hs/main" -x 200 -y 50

  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/repo:hs/main" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/repo:hs/main" "sleep"
  tmux -L "$OBON_TMUX_SOCKET" send-keys -t "hs/org/other:hs/main" "sleep 600" Enter
  wait_for_cmd "$OBON_TMUX_SOCKET" "hs/org/other:hs/main" "sleep"

  run "$OBON_BIN" join --all -y
  assert_success
  assert_output --partial "Joined 2 pane(s) into obon session"

  run tmux -L "$OBON_TMUX_SOCKET" has-session -t "obon"
  assert_success
}
