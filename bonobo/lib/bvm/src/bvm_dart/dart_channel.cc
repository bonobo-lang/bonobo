//
// Created by Tobe on 4/26/18.
//

#include <bvm/bvm.h>
#include "dart_channel.h"
#include <iostream>

bvm::DartChannel *bvm::dartChannel = nullptr;

bvm::DartChannel::DartChannel(Dart_Handle sendPort) {
    bvm::dartChannel = this;
    this->sendPort = sendPort;
    sendPortId = 0;
    Dart_SendPortGetId(sendPort, &this->sendPortId);
    this->receivePort =
            Dart_NewNativePort("machine", sendPortCallback, true);
    vm = new VM(this);
}

bvm::DartChannel *bvm::DartChannel::create(Dart_Handle sendPort) {
    return bvm::dartChannel != nullptr ? bvm::dartChannel : new DartChannel(sendPort);
}

const Dart_Port &bvm::DartChannel::get_receive_port() {
    return this->receivePort;
}

void bvm::DartChannel::sendPortCallback(Dart_Port destPortId, Dart_CObject *message) {
    bvm::dartChannel->handleDartMessage(destPortId, message);
}

void bvm::DartChannel::handleDartMessage(Dart_Port destPortId, Dart_CObject *message) {
    if (message->type == Dart_CObject_kArray && message->value.as_array.length >= 2) {
        char *msg = message->value.as_array.values[0]->value.as_string;

        if (!strcmp(msg, "EXEC")) {
            char *functionName = message->value.as_array.values[1]->value.as_string;
            execFunction(functionName, destPortId, message, true);
        } else if (!strcmp(msg, "FN")) {
            char *functionName = message->value.as_array.values[1]->value.as_string;
            loadFunction(functionName, destPortId, message);
        } else if (!strcmp(msg, "LOOP") && vm->get_loop_thread() == nullptr) {
            vm->startLoop();
        }
    }
}

void bvm::DartChannel::loadFunction(char *functionName, Dart_Port destPortId, Dart_CObject *message) {
    auto bytecode = message->value.as_array.values[2]->value.as_typed_data;
    vm->loadFunction(functionName, bytecode.length, bytecode.values);
}

void bvm::DartChannel::execFunction(char *functionName, Dart_Port destPortId, Dart_CObject *message, bool requestNew) {
    auto msgArgs = message->value.as_array.values[2]->value.as_array;
    auto *args = new void *[msgArgs.length - 2];
    memcpy(args, msgArgs.values + 2, (size_t) msgArgs.length - 2);
    vm->execFunction(functionName, msgArgs.length - 2, args, true);
}

void bvm::DartChannel::shutdown() {
    // Shut it down - send the exit code.
    auto *message = new Dart_CObject;
    message->type = Dart_CObject_kInt32;
    message->value.as_int32 = 0;
    Dart_PostCObject(sendPortId, message);
    Dart_CloseNativePort(receivePort);
}

void bvm::DartChannel::throwString(const char *str) {
    // THROW, $error
    auto *req1 = new Dart_CObject, *req2 = new Dart_CObject;
    req1->type = req2->type = Dart_CObject_kString;
    req1->value.as_string = (char *) "THROW";
    req2->value.as_string = (char*) str;
    Dart_PostCObject(sendPortId, req1);
    Dart_PostCObject(sendPortId, req2);
}

void bvm::DartChannel::notifyMissingMethod(const char *str) {

}
