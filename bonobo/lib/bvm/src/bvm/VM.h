#ifndef BVM_BVM_H
#define BVM_BVM_H

#include <thread>
#include <vector>
#include "bvm_task.h"
#include "channel.h"
#include "function.h"
#include "interpreter.h"

namespace bvm
{
    class VM
    {
    private:
        static void threadProc(VM *vm);

        Channel *channel;
        std::vector<BVMTask *> tasks;
        std::vector<BVMFunction *> functions;
        BVMInterpreter *interpreter;
        std::thread *loopThread = nullptr;
    public:
        explicit VM(Channel *channel);
        ~VM();

        const std::thread *get_loop_thread();

        void loadFunction(char *functionName, intptr_t length, uint8_t *data);

        BVMTask *execFunction(char *functionName, intptr_t argc, void **argv, bool requestNew);

        void startLoop();

    };
}

#endif