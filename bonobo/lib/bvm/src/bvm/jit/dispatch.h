//
// Created by Tobe on 4/27/18.
//

#ifndef PROJECT_DISPATCH_H
#define PROJECT_DISPATCH_H

#include <cstdint>
#include <vector>

namespace bvm
{
    typedef bool (*Dispatch)(std::vector<uint8_t> *data, uint8_t **bytecode);
    typedef void (*JittedCode)();

    bool dispatch_call(std::vector<uint8_t> *data, uint8_t **bytecode);
    bool dispatch_pop_param(std::vector<uint8_t> *data, uint8_t **bytecode);
    bool dispatch_push_param(std::vector<uint8_t> *data, uint8_t **bytecode);
    bool dispatch_print(std::vector<uint8_t> *data, uint8_t **bytecode);
    bool dispatch_ret(std::vector<uint8_t> *data, uint8_t **bytecode);
    bool dispatch_string(std::vector<uint8_t> *data, uint8_t **bytecode);
}

#endif //PROJECT_DISPATCH_H
