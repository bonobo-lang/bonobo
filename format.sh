#!/usr/bin/env bash
PWD=`pwd`
DIRNAME="$(cd "$(dirname "$0")" ; pwd -P )"
set -e

find $DIRNAME -type f ! -path '*.dart_tool*' -name '*.dart' | while read -r line; do
  dartfmt -w $line
done

