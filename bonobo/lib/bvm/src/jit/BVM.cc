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

void bvm::BVM::threadProc(bvm::BVMThreadConfig *config) {
    auto *bvm = (BVM *) config->bvm;

    while (!bvm->tasks.empty()) {
        bool done = false;

        for (auto *task: bvm->tasks) {
            // Check for error
            if (task->blocked) {
                if (!task->errorMessage.empty()) {
                    // THROW, $error
                    auto *req1 = new Dart_CObject, *req2 = new Dart_CObject;
                    req1->type = req2->type = Dart_CObject_kString;
                    req1->value.as_string = (char *) "THROW";
                    req2->value.as_string = (char *) task->errorMessage.c_str();
                    Dart_PostCObject(bvm->sendPortId, req1);
                    Dart_PostCObject(bvm->sendPortId, req2);
                    done = true;
                    break;
                } else if (task->missingFunction != nullptr) {
                    // The task in question is waiting for a function to run.
                    // Find the function in question, if it exists.
                    auto *newTask = bvm->execFunction((char *) task->missingFunction, config->destPortId,
                                                      config->message,
                                                      !task->functionRequested);
                    task->functionRequested = true;

                    if (newTask != nullptr) {
                        //std::cout << "Found function " << task->missingFunction << ". Continuing existing" << std::endl;
                        // We've started the function.
                        // Tell it where to return to, and assign the same stack.
                        newTask->message = nullptr;
                        newTask->stack = task->stack;
                        newTask->returnTo = task;

                        // Clear out the missingFunction.
                        task->missingFunction = nullptr;
                        task->functionRequested = false;
                        task->blocked = true;
                    }
                }
            } else if ((done = !bvm->interpreter->visit(task))) {
                if (!task->success) {
                    // TODO: Handle an error?
                }

                // Free the task.
                auto vec = bvm->tasks;
                vec.erase(std::remove(vec.begin(), vec.end(), task), vec.end());
                delete task;
                done = true;
            }
        }

        if (done) break;
    }

    // Shut it down - send the exit code.
    auto *message = new Dart_CObject;
    message->type = Dart_CObject_kInt32;
    message->value.as_int32 = 0;
    Dart_PostCObject(bvm->sendPortId, message);
    Dart_CloseNativePort(bvm->receivePort);
}

void bvm::BVM::handleDartMessage(Dart_Port destPortId, Dart_CObject *message) {
    if (message->type == Dart_CObject_kArray && message->value.as_array.length >= 2) {
        char *msg = message->value.as_array.values[0]->value.as_string;

        if (!strcmp(msg, "EXEC")) {
            char *functionName = message->value.as_array.values[1]->value.as_string;
            execFunction(functionName, destPortId, message, true);
        } else if (!strcmp(msg, "FN")) {
            char *functionName = message->value.as_array.values[1]->value.as_string;
            loadFunction(functionName, destPortId, message);
        } else if (!strcmp(msg, "LOOP") && bvmInstance->loopThread == nullptr) {
            auto* config = new bvm::BVMThreadConfig;
            config->bvm = bvmInstance;
            config->message = message;
            config->destPortId = destPortId;
            bvmInstance->loopThread = new std::thread(bvm::BVM::threadProc, config);
            bvmInstance->loopThread->detach();
        }
    }
}

void bvm::BVM::loadFunction(char *functionName, Dart_Port destPortId, Dart_CObject *message) {
    // Get the bytecode.
    auto bytecode = message->value.as_array.values[2]->value.as_typed_data;
    auto *function = new BVMFunction;
    function->name = functionName;
    function->length = bytecode.length;
    function->bytecode = new uint8_t[function->length];
    functions.push_back(function);

    for (intptr_t i = 0; i < bytecode.length; i++)
        function->bytecode[i] = bytecode.values[i];

    /*std::cout << "LOADED FUNCTION: " << functionName << ": [";


    for (intptr_t i = 0; i < bytecode.length; i++) {
        if (i > 0)
            std::cout << ", ";
        std::cout << "0x" << std::hex << (unsigned int) bytecode.values[i] << std::dec;
    }

    std::cout << "]" << std::endl;*/
}

bvm::BVMTask *bvm::BVM::execFunction(char *functionName, Dart_Port destPortId, Dart_CObject *message, bool requestNew) {
    // Find the function to run.
    BVMFunction *function = nullptr;

    for (auto *fn : functions) {
        //std::cout << fn->name << " vs. " << functionName << std::endl;
        if (!strcmp(fn->name, functionName)) {
            function = fn;
            break;
        }
    }

    if (function == nullptr) {
        if (requestNew) {
            // Request JIT-compilation of function.
            //
            // Send 'FN', then $fullName
            auto *req1 = new Dart_CObject, *req2 = new Dart_CObject;
            req1->type = req2->type = Dart_CObject_kString;
            req1->value.as_string = (char *) "FN";
            req2->value.as_string = new char[strlen(functionName) + 1];
            strcpy(req2->value.as_string, functionName);
            req2->value.as_string[strlen(functionName)] = 0;
            Dart_PostCObject(sendPortId, req1);
            Dart_PostCObject(sendPortId, req2);
            delete req1;
            delete req2;
        }

        return nullptr;
    } else {
        // Start a new task that invokes the function.
        auto *task = new BVMTask;
        task->returnTo = nullptr;
        task->stack = new std::stack<void *>;
        task->function = function;
        task->message = message;
        tasks.push_back(task);
        return task;
    }
}
