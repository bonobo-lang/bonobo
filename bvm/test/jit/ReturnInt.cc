#include <binary/binary.h>
#include <gtest/gtest.h>
#include <jit/JIT.h>
#include <stdint.h>

TEST(ReturnIntTest, ReturnInt) {
    auto *object = new bvm::Object;
    uint32_t value = 1;
    object->number_of_constants = 1;
    object->number_of_types = 0;
    object->number_of_functions = 1;
    object->constants = new bvm::Constant;
    object->constants->size = sizeof(uint32_t);
    object->constants->value = (void *) &value;
    object->functions = new bvm::Function;
    object->functions->number_of_instructions = 3;
    object->functions->instructions = new uint8_t[3];
    object->functions->instructions[0] = (uint8_t) bvm::Opcode::CONSTANT8;
    object->functions->instructions[1] = 0;
    object->functions->instructions[2] = (uint8_t) bvm::Opcode::RET;

    auto *jit = new bvm::JIT;
    jit->run(object);
}