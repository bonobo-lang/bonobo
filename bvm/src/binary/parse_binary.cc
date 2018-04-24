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

    return nullptr;
}