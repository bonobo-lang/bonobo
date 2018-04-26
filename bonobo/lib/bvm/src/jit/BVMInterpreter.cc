//
// Created by Tobe on 4/25/18.
//

#include <sstream>
#include <dart_native_api.h>
#include "../binary/Opcode.h"
#include "BVMInterpreter.h"
#include "Function.h"

bool bvm::BVMInterpreter::visit(bvm::BVMTask *task) {
    // Get the arguments.
    auto arguments = task->message->value.as_array.values[2]->value.as_array;

    if (!task->started) {
        // Push all arguments onto the stack, in reverse order.
        for (intptr_t i = arguments.length - 1; i >= 0; i--) {
            task->stack.push(arguments.values[i]->value.as_string);
        }
    }

    while (!task->blocked) {
        while (task->index < task->function->length) {
            auto opcode = (Opcode) task->function->bytecode[task->index++];

            switch (opcode) {
                case Opcode::POP_PARAM: {
                    // Pop a parameter from the stack
                    task->parameters.push_back(task->stack.top());
                    task->stack.pop();
                    break;
                }
                case Opcode::PUSH_PARAM: {
                    // Push a parameter to the stack
                    auto idx = task->stack.top();
                    task->stack.pop();
                    task->stack.push(task->parameters.at((unsigned long) idx));
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

                    task->strings.push(ss.str());
                    break;
                }
                    /*
                case Opcode::CALL:
                    break;
                case Opcode::RET:
                    break;
                */
                default: {
                    // TODO: Throw error
                    task->blocked = true;
                    task->errorMessage.append("Invalid opcode: ");
                    task->errorMessage.append(std::to_string((unsigned int) opcode));
                    break;
                }
            }
        }
    }

    if (task->index == task->function->length - 1) {
        // Task is complete, dispose of it
        delete task;
    }

    return true;
}
