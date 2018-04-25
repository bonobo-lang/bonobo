#ifndef BVM_BVM_H
#define BVM_BVM_H

#include <llvm/IR/IRBuilder.h>
#include <dart_api.h>
#include <dart_native_api.h>
#include <vector>
#include "BVMTask.h"
#include "Function.h"

namespace bvm
{

    class BVM
    {
    private:
        explicit BVM(Dart_Handle sendPort);
        std::vector<BVMTask*> tasks;
        std::vector<BVMFunction*> functions;
        Dart_Port receivePort;
        Dart_Handle sendPort;
    public:
        static BVM *create(Dart_Handle sendPort);

        const Dart_Port &get_receive_port();

        static void sendPortCallback(Dart_Port destPortId, Dart_CObject *message);

        void handleDartMessage(Dart_Port destPortId, Dart_CObject *message);

        void loadFunction(char* functionName, Dart_Port destPortId, Dart_CObject *message);

        void execFunction(char *functionName, Dart_Port destPortId, Dart_CObject *message);
    };

#ifndef BVM_INSTANCE
#define BVM_INSTANCE
    extern BVM *bvmInstance;
#endif
}

#endif