//
// Created by Tobe on 4/25/18.
//

#include <cstring>
#include <iostream>
#include <sstream>
#include "opcode.h"
#include "interpreter.h"

bool bvm::BVMInterpreter::visit(bvm::BVMTask *task) {
    if (!task->started) {
        if (task->argc > 0) {
            // Get the arguments.
            // Push all arguments onto the stack-> in reverse order.
            for (intptr_t i = task->argc - 1; i >= 0; i--) {
                task->stack->push(task->argv[i]);
            }
        }

        task->started = true;

        /*std::cout << "Running function " << task->function->name << ":" << std::endl;

        for (intptr_t i = 0; i < task->function->length; i++) {
            if (i > 0)
                std::cout << ", ";
            std::cout << "0x" << std::hex << (unsigned int) task->function->bytecode[i] << std::dec;
        }*/
    }

    while (!task->blocked && task->index < task->function->length) {
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
                    ss << std::noskipws << ch;
                    //ss.write(&ch, 1);
                    ch = (char) task->function->bytecode[task->index++];
                }

                auto str = ss.str();
                auto buf = new char[str.length()];
                strcpy(buf, str.c_str());
                //std::cout << "STRING: " << str << std::endl;
                task->stack->push((void *) buf);
                break;
            }

            case Opcode::CALL: {
                // If we're calling a function, then the value at the top
                // of the string stack is a const char*.
                auto functionName = (const char *) task->stack->top();
                task->stack->pop();
                //std::cout << "CALLING: " << functionName << std::endl;

                // Signal to the VM that we want to call this function.
                task->blocked = true;
                task->missingFunction = functionName;
                return true;
            }
            case Opcode::RET: {
                // We're done.
                task->index = task->function->length + 1;
                break;
            }
            case Opcode::PRINT: {
                // The top of the stack is a const char*.
                // Print it.
                auto msg = (const char *) task->stack->top();
                std::cout << msg << std::endl;
                delete msg;
                task->stack->pop();
                break;
            }
            case Opcode::ALLOCATE: {
                // The top of the stack is a long.
                // Read it, then push the new pointer.
                auto size = *((uint64_t *) task->stack->top());
                task->stack->pop();
                task->stack->push(malloc(size));
                break;
            }
            case Opcode::FREE: {
                // Free the pointer at the top of the stack,
                // for better or worse.
                free(task->stack->top());
                task->stack->pop();
                break;
            }
            case Opcode::GET : {
                // There's a string in the stack.
                // Get the value of the corresponding variable.
                // SSA FTW.
                auto str = std::string((const char*) task->stack->top());
                task->stack->pop();
                task->stack->push(task->variables[str]);
                break;
            }
            case Opcode::SET : {
                // The top is the value in question.
                // The next is a string.
                // Set the corresponding variable.
                auto *value = task->stack->top();
                task->stack->pop();
                auto str = std::string((const char*) task->stack->top());
                task->stack->pop();
                task->variables[str] = value;
                break;
            }
            default: {
                // Throw error
                std::stringstream ssErr;
                ssErr << "Invalid opcode at index 0x" << std::hex << (task->index - 1);
                ssErr << ": 0x" << std::hex << (int) task->function->bytecode[task->index - 1];
                ssErr << std::dec;
                task->blocked = true;
                task->errorMessage.clear();
                task->errorMessage += ssErr.str();
                break;
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

        task->success = true;
        return false;
    }

    return true;
}
