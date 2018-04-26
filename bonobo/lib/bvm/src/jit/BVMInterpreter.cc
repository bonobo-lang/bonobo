//
// Created by Tobe on 4/25/18.
//

#include <iostream>
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
            /*
            std::cout << "wtf" << std::endl;

            for (intptr_t i = 0; i < task->function->length; i++) {
                if (i > 0)
                    std::cout << ", ";
                std::cout << "0x" << std::hex << (unsigned int) task->function->bytecode[i] << std::dec;
            }
            */

            intptr_t index = task->index++;
            auto opcode = (Opcode) task->function->bytecode[index];

            /*std::cout << "Index: " << index << ", OP: 0x" << std::hex << (unsigned int) task->function->bytecode[index]
                      << std::dec
                      << std::endl;*/

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
                        //std::cout << "char: " << ch << std::endl;
                        ss.write(&ch, 1);
                        ch = (char) task->function->bytecode[task->index++];
                    }

                    auto str = ss.str();
                    auto buf = new char[str.length()];
                    strcpy(buf, str.c_str());
                    //std::cout << "STRING: " << str << std::endl;
                    task->stack->push((void*) buf);
                    break;
                }

                case Opcode::CALL: {
                    // If we're calling a function, then the value at the top
                    // of the string stack is a const char*.
                    auto functionName = (const char*) task->stack->top();
                    task->stack->pop();
                    //std::cout << "CALLING: " << functionName << std::endl;

                    // Signal to the VM that we want to call this function.
                    task->blocked = true;
                    task->missingFunction = functionName;
                    break;
                }
                case Opcode::RET: {
                    // We're done.
                    task->index = task->function->length;
                    break;
                }
                case Opcode::PRINT: {
                    // The top of the stack is a const char*.
                    // Print it.
                    auto msg = (const char*) task->stack->top();
                    task->stack->pop();
                    std::cout << "YEEEAHHHH " << msg << std::endl;
                    break;
                }
                default: {
                    break;
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

    if (task->index >= task->function->length - 1) {
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
