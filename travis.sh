#!/usr/bin/env bash
CORES=2
DIRNAME="$(cd "$(dirname "$0")" ; pwd -P )"
set -e

function run_tests() {
  cd "$DIRNAME/$1" && pub get && pub run test -j $CORES
  cd $DIRNAME
}


# Build the embedded JIT
cd "$DIRNAME/bonobo"
cmake .
cmake --build . --target bvm_jit -- -j $CORES

# Run all the tests
run_tests bonobo
#"$DIRNAME/bvm/test/jit/return_int"
