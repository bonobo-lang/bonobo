#include <stdint.h>
#include "parse_binary.h"
#include "Object.h"

bvm::Object *bvm::parseBinary(std::istream &stream) {
    // The first 96 bits should be:
    // * The magic number: 0xB090BO ("Bonobo")
    // * An arbitrary 32-bit number
    // * A checksum: (magic % arbitrary) >> 2
    //
    // This is how we verify that the provided binary is Bonobo code.
    int32_t magic, arbitrary, checksum;
    stream.read((char *) &magic, sizeof(magic));
    stream.read((char *) &arbitrary, sizeof(arbitrary));
    stream.read((char *) &checksum, sizeof(checksum));

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
    stream.read((char *) &object->number_of_constants, sizeof(int64_t));
    stream.read((char *) &object->number_of_types, sizeof(int64_t));
    stream.read((char *) &object->number_of_functions, sizeof(int64_t));

    // Parse constants.
    Constant *constant;

    for (int64_t i = 0; i < object->number_of_constants; i++) {
        int64_t len;
        uint8_t size;
        stream.read((char *) &len, sizeof(len));
        stream.read((char *) &size, sizeof(size));
        auto *name = new char[len];
        auto *newConstant = new bvm::Constant;
        newConstant->name = name;
        newConstant->size = size;
        constant = object->constants == nullptr ? constant = object->constants = newConstant
                                                : constant->next = newConstant;
    }

    // Parse types.
    Type *type;
    for (int64_t i = 0; i < object->number_of_types; i++) {
        int64_t len;
        uint8_t size;
        stream.read((char *) &len, sizeof(len));
        stream.read((char *) &size, sizeof(size));
        auto *name = new char[len];
        auto *newType = new bvm::Type;
        newType->name = name;
        newType->size = size;
        type = object->types == nullptr ? type = object->types = newType : type->next = newType;
    }

    // Parse functions.
    Function *function;

    for (int64_t i = 0; i < object->number_of_functions; i++) {
        uint64_t len;
        auto *newFunction = new Function;

        // Parse name.
        stream.read((char *) &len, sizeof(len));
        newFunction->name = new char[len];
        stream.read((char *) newFunction->name, len);

        // Get parameter count.
        stream.read((char *) &len, sizeof(len));
        newFunction->number_of_parameters = len;
        newFunction->parameters = new uint8_t[len];
        stream.read((char *) newFunction->parameters, len);

        // Parse instructions.
        stream.read((char *) &len, sizeof(len));
        newFunction->number_of_instructions = len;
        newFunction->instructions = new uint8_t[len];
        stream.read((char *) newFunction->instructions, len);
        function = object->functions == nullptr ? function = object->functions = newFunction
                                                : function->next = newFunction;
    }

    return nullptr;
}