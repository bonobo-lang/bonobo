//
// Created by Tobe on 4/25/18.
//

#include <cstring>
#include <libtcc.h>
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
    else if (strcmp("compileC", cname) == 0) result = compile_c;

    return result;
}

void new_jit(Dart_NativeArguments arguments) {
    Dart_Handle rawSendPort = Dart_GetNativeArgument(arguments, 0);
    auto *jit = bvm::DartChannel::create(rawSendPort);
    Dart_SetReturnValue(arguments, Dart_NewSendPort(jit->get_receive_port()));
}

void compile_c(Dart_NativeArguments arguments) {
    const char *c_src;
    bool isExecutable;
    HandleError(Dart_StringToCString(Dart_GetNativeArgument(arguments, 0), &c_src));
    Dart_GetNativeBooleanArgument(arguments, 1, &isExecutable);

    auto *tcc = tcc_new();

    if (!tcc) {
        Dart_ThrowException(Dart_NewStringFromCString("Could not instantiate TCC compiler backend."));
        return;
    }

    tcc_set_output_type(tcc, isExecutable ? TCC_OUTPUT_EXE : TCC_OUTPUT_MEMORY);

    if (tcc_compile_string(tcc, c_src) == -1) {
        Dart_ThrowException(Dart_NewStringFromCString("C compilation failed."));
        return;
    }

    auto size = tcc_relocate(tcc, nullptr);

    if (size == -1) {
        Dart_ThrowException(Dart_NewStringFromCString("C compilation produced empty binary."));
        return;
    }

    auto *mem = malloc((size_t) size);
    tcc_relocate(tcc, mem);

    Dart_Handle buf = HandleError(Dart_NewExternalTypedData(Dart_TypedData_kUint8, mem, size));
    Dart_SetReturnValue(arguments, buf);
    tcc_delete(tcc);
}
