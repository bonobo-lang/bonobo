//
// Created by Tobe on 4/25/18.
//

#ifndef PROJECT_EXTENSION_H
#define PROJECT_EXTENSION_H

#include <dart_api.h>

DART_EXPORT Dart_Handle bvm_jit_dart_Init(Dart_Handle parent_library);

Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool *auto_setup_scope);

void new_jit(Dart_NativeArguments arguments);

#endif //PROJECT_EXTENSION_H
