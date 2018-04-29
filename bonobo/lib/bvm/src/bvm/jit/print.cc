//
// Created by Tobe on 4/27/18.
//

#include "dispatch.h"

bool bvm::dispatch_print(std::vector<uint8_t> *data, uint8_t **bytecode) {
    (*bytecode)++;
    return true;
}

bool bvm::dispatch_call(std::vector<uint8_t> *data, uint8_t **bytecode) {
    (*bytecode)++;
    return true;
}

bool bvm::dispatch_pop_param(std::vector<uint8_t> *data, uint8_t **bytecode) {
    (*bytecode)++;
    return true;
}

bool bvm::dispatch_push_param(std::vector<uint8_t> *data, uint8_t **bytecode) {
    (*bytecode)++;
    return true;
}

bool bvm::dispatch_ret(std::vector<uint8_t> *data, uint8_t **bytecode) {
    (*bytecode)++;
    // TODO: Return with types?
    data->push_back(0xC3);
    return true;
}

bool bvm::dispatch_string(std::vector<uint8_t> *data, uint8_t **bytecode) {
    // String is a constant that starts at the current offset + 1.

    // TODO: Add the whole string
    while (*((*bytecode)++) != 0) {
        // Loop...
    }

    // For now, just add the first character.

    /*auto str = (uint32_t) (bytecode + 1);
    auto *chars =(uint8_t*) &str;

    // We want to push this string to the stack.
    data->push_back(0x64);

    for (int i = 0; i < 4; i++) {
        data->push_back(chars[i]);
    }
*/

    (*bytecode)++;
    return true;
}
