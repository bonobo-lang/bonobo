#include <stdint.h>
#include "parse_binary.h"

bvm::Object *bvm::parseBinary(std::istream &stream)
{
    // The first 96 bits should be:
    // * The magic number: 0xB090BO ("Bonobo")
    // * An arbitrary 32-bit number
    // * A checksum: (magic % arbitrary) >> 2
    //
    // This is how we verify that the provided binary is Bonobo code.
    int32_t magic, arbitrary, checksum;
    stream.read((char*)&magic, sizeof(magic));
    stream.read((char*)&arbitrary, sizeof(arbitrary));
    stream.read((char*)&checksum, sizeof(checksum));

    if (!stream)
        return nullptr;

    // Verify the checksum.
    if (checksum != ((magic % arbitrary) >> 2))
        return nullptr;

    // Next, we expect:
    // * The number of constants
    // * The number of types
    // * The number of functions
    auto *object = new bvm::Object;
    stream.read((char*) &object->number_of_constants, sizeof(int64_t));
    stream.read((char*) &object->number_of_types, sizeof(int64_t));
    stream.read((char*) &object->number_of_functions, sizeof(int64_t));

    object->constants = new bvm::Constant*[object->number_of_constants];
    object->types = new bvm::Type*[object->number_of_types];
    object->functions = new bvm::Function*[object->number_of_functions];

    // Parse constants.
    for (int64_t i = 0; i < object->number_of_constants; i++) {
        int64_t len;
        uint8_t size;
        stream.read((char*) &len, sizeof(len));
        stream.read((char*) &size, sizeof(size));
        auto *name = new char[len];
        auto *constant = object->constants[i] = new bvm::Constant;
        constant->name = name;
        constant->size = size;
    }

    // Parse types.
    for (int64_t i = 0; i < object->number_of_types; i++) {
        int64_t len;
        uint8_t size;
        stream.read((char*) &len, sizeof(len));
        stream.read((char*) &size, sizeof(size));
        auto *name = new char[len];
        auto *type = object->types[i] = new bvm::Type;
        type->name = name;
        type->size = size;
    }

    // Parse functions.
    for (int64_t i = 0; i < object->number_of_functions; i++) {
        uint64_t len;
        auto *function = object->functions[i] = new Function;

        // Parse name.
        stream.read((char*) &len, sizeof(len));
        function->name = new char[len];
        stream.read((char*)function->name, len);

        // Get parameter count.
        stream.read((char*) &len, sizeof(len));
        function->number_of_parameters = len;
        function->parameters = new uint8_t[len];
        stream.read((char*)function->parameters, len);

        // Parse instructions.
        stream.read((char*) &len, sizeof(len));
        function->number_of_instructions = len;
        function->instructions = new Opcode[len];
        stream.read((char*)function->instructions, len);
    }

    return nullptr;
}