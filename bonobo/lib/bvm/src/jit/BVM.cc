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
            std::cout << "LOOP! Tasks: " << tasks.size()  << std::endl;
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

    if (true || function == nullptr) {
        // Request JIT-compilation of function.
        //
        // Send 'FN', then $fullName

        auto *req1 = new Dart_CObject, *req2 = new Dart_CObject;
        req1->type = req2->type = Dart_CObject_kString;
        req1->value.as_string = (char*) "FN";
        req2->value.as_string = functionName;
        Dart_PostCObject(sendPortId, req1);
        Dart_PostCObject(sendPortId, req2);
        delete req1;
        delete req2;
        /*auto *req = new Dart_CObject;
        req->type = Dart_CObject_kArray;
        auto *arr = new Dart_CObject*[2];
        arr[0] = new Dart_CObject;
        arr[1] = new Dart_CObject;
        arr[0]->type = arr[1]->type = Dart_CObject_kString;
        arr[0]->value.as_string = (char *) "FN";
        arr[1]->value.as_string = functionName;
        req->value.as_array.values = arr;
        Dart_PostCObject(destPortId, req);
        Dart_PostCObject(sendPortId, req);*/
        //delete[] arr;
        //delete req;
    } else {
        // Start a new task that invokes the function.
        auto *task = new BVMTask;
        task->function = function;
        task->message = message;
        tasks.push_back(task);
    }
}
