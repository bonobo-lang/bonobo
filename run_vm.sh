#!/usr/bin/env bash
cd bonobo
cmake .
cmake --build . --target bvm_jit -- -j 4
cd "../example/$1"
dart ../../bonobo/bin/bonobo.dart run
cd ../..
