#!/usr/bin/env bash
CORES=2
set -e

function run_tests() {
  cd $1 && pub get && pub run test -j $CORES
}

run_tests ast
run_tests scanner
run_tests parser
run_tests bonobo

