#include <dart_native_api.h>
#include <iostream>
#include "../binary/binary.h"
#include "BVM.h"
#include "extension.h"
#include "Function.h"

bvm::BVM *bvm::bvmInstance = nullptr;

bvm::BVM::BVM(Dart_Handle sendPort) {
    bvm::bvmInstance = this;
    this->sendPort = sendPort;
    Dart_SendPortGetId(sendPort, &this->sendPortId);
    this->receivePort =
            Dart_NewNativePort("BVM", sendPortCallback, true);
    interpreter = new BVMInterpreter;
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
        } else if (!strcmp(msg, "LOOP")) {
            while (true) {
                bool failed = false;

                for (auto *task: tasks) {
                    // Check for error
                    if (task->blocked && !task->errorMessage.empty()) {
                        // THROW, $error
                        auto *req1 = new Dart_CObject, *req2 = new Dart_CObject;
                        req1->type = req2->type = Dart_CObject_kString;
                        req1->value.as_string = (char *) "THROW";
                        req2->value.as_string = (char*) task->errorMessage.c_str();
                        Dart_PostCObject(sendPortId, req1);
                        Dart_PostCObject(sendPortId, req2);
                        failed = true;
                        break;
                    }

                    if ((failed = !interpreter->visit(task)))
                        break;
                }

                if (failed) break;
            }
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

    for (auto *fn : functions) {
        if (!strcmp(fn->name, functionName)) {
            function = fn;
            break;
        }
    }

    if (function == nullptr) {
        // Request JIT-compilation of function.
        //
        // Send 'FN', then $fullName
        auto *req1 = new Dart_CObject, *req2 = new Dart_CObject;
        req1->type = req2->type = Dart_CObject_kString;
        req1->value.as_string = (char *) "FN";
        req2->value.as_string = functionName;
        Dart_PostCObject(sendPortId, req1);
        Dart_PostCObject(sendPortId, req2);
        delete req1;
        delete req2;
    } else {
        // Start a new task that invokes the function.
        auto *task = new BVMTask;
        task->function = function;
        task->message = message;
        tasks.push_back(task);
    }
}
