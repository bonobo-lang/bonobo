#include <iostream>
#include "VM.h"
#include "bvm.h"

bvm::VM::VM(Channel *channel) {
    this->channel = channel;
    interpreter = new BVMInterpreter;
}

bvm::VM::~VM() {
    tasks.clear();
    delete interpreter;
}

std::vector<bvm::BVMTask *> *bvm::VM::get_tasks() {
    return &tasks;
}

void bvm::VM::threadProc(VM *vm) {
    while (!vm->tasks.empty()) {
        bool done = false;

        for (auto *task: vm->tasks) {
            // Check for error
            if (task->blocked) {
                if (!task->errorMessage.empty()) {
                    vm->channel->throwString(task->errorMessage.c_str());
                    done = true;
                    break;
                } else if (task->missingFunction != nullptr) {
                    // The task in question is waiting for a function to run.
                    // Find the function in question, if it exists.
                    auto *newTask = vm->execFunction((char *) task->missingFunction, 0, nullptr,
                                                     !task->functionRequested);
                    task->functionRequested = true;

                    if (newTask != nullptr) {
                        //std::cout << "Found function " << task->missingFunction << ". Continuing existing" << std::endl;
                        // We've started the function.
                        // Tell it where to return to, and assign the same stack.
                        newTask->stack = task->stack;
                        newTask->returnTo = task;

                        // Clear out the missingFunction.
                        task->missingFunction = nullptr;
                        task->functionRequested = false;
                        task->blocked = true;
                    }
                }
            } else if ((done = !vm->interpreter->visit(task))) {
                if (!task->success) {
                    if (!task->errorMessage.empty())
                        vm->channel->throwString(task->errorMessage.c_str());
                }

                // Free the task.
                auto vec = vm->tasks;
                unsigned long idx = 0;

                while (vec.at(idx) != task && idx < vec.size())
                    idx++;

                vec.erase(vec.begin() + idx);
                //vec.erase(std::remove(vec.begin(), vec.end(), task), vec.end());
                delete task;
                done = true;
            }
        }

        if (done) break;
    }

    vm->channel->shutdown();
}

void bvm::VM::loadFunction(char *functionName, intptr_t length, uint8_t *data) {
    // Get the bytecode.
    auto *function = new BVMFunction;
    function->name = new char[strlen(functionName) + 1];
    strcpy(function->name, functionName);
    function->name[strlen(functionName)] = 0;
    function->length = length;
    function->bytecode = new uint8_t[length];
    memcpy(function->bytecode, data, (size_t) length);
    functions.push_back(function);

    /*std::cout << "LOADED FUNCTION: " << functionName << ": [";


    for (intptr_t i = 0; i < bytecode.length; i++) {
        if (i > 0)
            std::cout << ", ";
        std::cout << "0x" << std::hex << (unsigned int) bytecode.values[i] << std::dec;
    }

    std::cout << "]" << std::endl;*/
}

bvm::BVMTask *bvm::VM::execFunction(char *functionName, intptr_t argc, void **argv, bool requestNew) {
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
        if (requestNew)
            // Request JIT-compilation of function.
            channel->notifyMissingMethod(functionName);
        return nullptr;
    } else {
        // Start a new task that invokes the function.
        auto *task = new BVMTask;
        task->returnTo = nullptr;
        task->stack = new std::stack<void *>;
        task->function = function;
        task->argc = argc;
        task->argv = argv;
        tasks.push_back(task);
        return task;
    }
}

const std::thread *bvm::VM::get_loop_thread() {
    return loopThread;
}

void bvm::VM::startLoop() {
    loopThread = new std::thread(threadProc, this);
    loopThread->detach();
}
