//
// Created by Tobe on 4/25/18.
//

#include "BVMInterpreter.h"
#include "Function.h"

bool bvm::BVMInterpreter::visit(bvm::BVMTask *task) {
    // Get the arguments.
    auto arguments = task->message->value.as_array.values[2]->value.as_array;

    while (!task->blocked) {
        while (task->index < task->function->length) {

        }
    }

    if (task->index == task->function->length - 1) {
        // Task is complete, dispose of it
        delete task;
    }

    return true;
}
