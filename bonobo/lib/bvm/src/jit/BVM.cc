#include <dart_native_api.h>
#include <iostream>
#include "../binary/binary.h"
#include "BVM.h"
#include "Function.h"

bvm::BVM *bvm::bvmInstance = nullptr;

bvm::BVM::BVM(Dart_Handle sendPort) {
    bvm::bvmInstance = this;
    this->sendPort = sendPort;
    this->receivePort =
            Dart_NewNativePort("BVM", sendPortCallback, true);
}

bvm::BVM *bvm::BVM::create(Dart_Handle sendPort) {
    return bvm::bvmInstance != nullptr ? bvm::bvmInstance : new BVM(sendPort);
}

const Dart_Port &bvm::BVM::get_receive_port() {
    return this->receivePort;
}

void bvm::BVM::sendPortCallback(Dart_Port destPortId, Dart_CObject *message) {
    bvm::bvmInstance->handleDartMessage(destPortId, message);
}

void bvm::BVM::handleDartMessage(Dart_Port destPortId, Dart_CObject *message) {
    if (message->type == Dart_CObject_kArray && message->value.as_array.length >= 2) {
        char *msg = message->value.as_array.values[0]->value.as_string;

        if (!strcmp(msg, "EXEC")) {
            char *functionName = message->value.as_array.values[1]->value.as_string;
            execFunction(functionName, destPortId, message);
        } else if (!strcmp(msg, "FN")) {
            char *functionName = message->value.as_array.values[1]->value.as_string;
            loadFunction(functionName, destPortId, message);
        }
    }
}

void bvm::BVM::loadFunction(char *functionName, Dart_Port destPortId, Dart_CObject *message) {
    // Get the bytecode.
    auto bytecode = message->value.as_array.values[2]->value.as_typed_data;
    auto *function = new BVMFunction;
    function->name = functionName;
    function->length = bytecode.length;
    function->bytecode = bytecode.values;
    functions.push_back(function);
}

void bvm::BVM::execFunction(char *functionName, Dart_Port destPortId, Dart_CObject *message) {
    // Find the function to run.
    BVMFunction *function = nullptr;

    for (auto * fn : functions) {
        if (!strcmp(fn->name, functionName)) {
            function = fn;
            break;
        }
    }

    if (function == nullptr) {
        // TODO: Request JIT-compilation of function.
    }

    // Get the arguments.
    auto arguments = message->value.as_array.values[2]->value.as_array;

    // TODO: Invoke the function in question.
}
