#!/usr/bin/env bats

setup() {
  load test_helper/common
}

@test "obon --version shows version" {
  run "$OBON_BIN" --version
  assert_success
  assert_output --partial "obon"
}

@test "obon --help shows usage" {
  run "$OBON_BIN" --help
  assert_success
  assert_output --partial "Usage:"
}

@test "obon with no arguments shows usage and exits with error" {
  run "$OBON_BIN"
  assert_failure
  assert_output --partial "Usage:"
}

@test "obon -v shows version" {
  run "$OBON_BIN" -v
  assert_success
  assert_output --partial "obon"
}

@test "obon -h shows usage" {
  run "$OBON_BIN" -h
  assert_success
  assert_output --partial "Usage:"
}

@test "obon with unknown command exits with error" {
  run "$OBON_BIN" unknown
  assert_failure
  assert_output --partial "unknown command"
}
