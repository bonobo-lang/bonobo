//
// Created by Tobe on 4/25/18.
//

#include <cstring>
#include "dart_channel.h"
#include "extension.h"

DART_EXPORT Dart_Handle bvm_dart_Init(Dart_Handle parent_library) {
    if (Dart_IsError(parent_library)) return parent_library;

    Dart_Handle result_code =
            Dart_SetNativeResolver(parent_library, ResolveName, nullptr);
    if (Dart_IsError(result_code)) return result_code;

    return Dart_Null();
}

Dart_Handle HandleError(Dart_Handle handle) {
    if (Dart_IsError(handle)) Dart_PropagateError(handle);
    return handle;
}

Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool *auto_setup_scope) {
    // If we fail, we return nullptr, and Dart throws an exception.
    if (!Dart_IsString(name)) return nullptr;
    Dart_NativeFunction result = nullptr;
    const char *cname;
    HandleError(Dart_StringToCString(name, &cname));

    if (strcmp("NewJIT", cname) == 0) result = new_jit;

    return result;
}

void new_jit(Dart_NativeArguments arguments) {
    Dart_Handle rawSendPort = Dart_GetNativeArgument(arguments, 0);
    auto *jit = bvm::DartChannel::create(rawSendPort);
    Dart_SetReturnValue(arguments, Dart_NewSendPort(jit->get_receive_port()));
}
