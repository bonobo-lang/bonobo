#ifndef PROJECT_DART_CHANNEL_H
#define PROJECT_DART_CHANNEL_H

#include <bvm/bvm.h>
#include <dart_api.h>
#include <dart_native_api.h>

namespace bvm
{
    class DartChannel : public Channel
    {
    private:
        explicit DartChannel(Dart_Handle sendPort);
        Dart_Port receivePort, sendPortId;
        Dart_Handle sendPort;
        VM *vm;
    public:

        static DartChannel *create(Dart_Handle sendPort);

        const Dart_Port &get_receive_port();

        static void sendPortCallback(Dart_Port destPortId, Dart_CObject *message);

        void handleDartMessage(Dart_Port destPortId, Dart_CObject *message);

        void loadFunction(char *functionName, Dart_Port destPortId, Dart_CObject *message);

        void execFunction(char *functionName, Dart_Port destPortId, Dart_CObject *message, bool requestNew);

    private:
        void notifyMissingMethod(const char *str) override;

        void shutdown() override;

        void throwString(const char *str) override;
    };

    extern DartChannel *dartChannel;
}


#endif PROJECT_DART_CHANNEL_H
