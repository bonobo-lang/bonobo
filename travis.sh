#!/usr/bin/env bash
CORES=2
DIRNAME="$(cd "$(dirname "$0")" ; pwd -P )"
set -e

function run_tests() {
  cd "$DIRNAME/$1" && pub get && pub run test -j $CORES
  cd $DIRNAME
}

run_tests bonobo

# Build everything
cd "$DIRNAME/bvm"
cmake .
cmake --build . --target all -- -j $CORES

# Run all the tests
"$DIRNAME/bvm/test/jit/return_int"
