#ifndef BVM_BVM_H
#define BVM_BVM_H

#include <llvm/IR/IRBuilder.h>
#include <dart_api.h>
#include <dart_native_api.h>

namespace bvm
{
    class BVM
    {
    private:
        Dart_Port receivePort;
        Dart_Handle sendPort;
    public:
        explicit BVM(Dart_Handle sendPort);

        const Dart_Port &get_receive_port();

        void handleDartMessage(Dart_Port destPortId, Dart_CObject *message);
    };
}

#endif