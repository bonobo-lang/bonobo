#!/usr/bin/env bash
CORES=2
DIRNAME="$(cd "$(dirname "$0")" ; pwd -P )"
set -e

function run_tests() {
  cd "$DIRNAME/$1" && pub get && pub run test -j $CORES
  cd $DIRNAME
}

# run_tests ast
run_tests scanner
run_tests parser
# run_tests bonobo

