//
// Created by Tobe on 4/25/18.
//

#include <sstream>
#include <dart_native_api.h>
#include "../binary/Opcode.h"
#include "BVMInterpreter.h"
#include "Function.h"

bool bvm::BVMInterpreter::visit(bvm::BVMTask *task) {
    if (!task->started) {
        if (task->message != nullptr) {
            // Get the arguments.
            auto arguments = task->message->value.as_array.values[2]->value.as_array;
            // Push all arguments onto the stack-> in reverse order.
            for (intptr_t i = arguments.length - 1; i >= 0; i--) {
                task->stack->push(arguments.values[i]->value.as_string);
            }
        }

        task->started = true;
    }

    while (!task->blocked) {
        while (!task->blocked && task->index < task->function->length) {
            auto opcode = (Opcode) task->function->bytecode[task->index++];

            switch (opcode) {
                case Opcode::POP_PARAM: {
                    // Pop a parameter from the stack
                    task->parameters.push_back(task->stack->top());
                    task->stack->pop();
                    break;
                }
                case Opcode::PUSH_PARAM: {
                    // Push a parameter to the stack
                    auto idx = task->stack->top();
                    task->stack->pop();
                    task->stack->push(task->parameters.at((unsigned long) idx));
                    break;
                }
                case Opcode::STRING: {
                    // Read a string from program, byte-for-byte
                    std::stringstream ss;
                    auto ch = (char) task->function->bytecode[task->index++];

                    while (ch != 0) {
                        ss.write(&ch, 1);
                        ch = (char) task->function->bytecode[task->index++];
                    }

                    task->stack->push((void *) ss.str().c_str());
                    break;
                }

                case Opcode::CALL: {
                    // If we're calling a function, then the value at the top
                    // of the stack->is a const char*.
                    auto *functionName = (const char *) task->stack->top();

                    // Signal to the VM that we want to call this function.
                    task->blocked = true;
                    task->missingFunction = functionName;
                    break;
                }
                case Opcode::RET: {
                    // We're done.
                    task->index = task->function->length - 1;
                    break;
                }
                default: {
                    // Throw error
                    task->blocked = true;
                    task->errorMessage.clear();
                    task->errorMessage.append("Invalid opcode at index ");
                    task->errorMessage.append(std::to_string(task->index - 1));
                    task->errorMessage.append(": ");
                    task->errorMessage.append(std::to_string(task->function->bytecode[task->index - 1]));
                    break;
                }
            }
        }
    }

    if (task->index == task->function->length - 1) {
        // If there is a task waiting on this one,
        // we want to send the value at the top of this stack
        // to the top of the caller's stack->
        if (task->returnTo != nullptr) {
            // If this function returned void, don't push anything, obviously.
            if (!task->stack->empty()) {
                task->returnTo->stack->push(task->stack->top());
                task->stack->pop();
            }
        }

        // Task is complete, dispose of it.
        delete task;
    }

    return true;
}
