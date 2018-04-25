#include <iostream>
#include "BVM.h"

bvm::BVM::BVM(Dart_Handle sendPort) {
    this->sendPort = sendPort;
    this->receivePort =
            Dart_NewNativePort("BVM", this->handleDartMessage, true);
}

const Dart_Port &bvm::BVM::get_receive_port() {
    return this->receivePort;
}


void bvm::BVM::handleDartMessage(Dart_Port destPortId, Dart_CObject *message) {
    std::cout << "Yay!" << std::endl;
}
