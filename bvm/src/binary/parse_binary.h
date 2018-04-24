#ifndef BVM_BVMBINARYREADER_H
#define BVM_BVMBINARYREADER_H
#include <istream>
#include "Object.h"
#include "Opcode.h"

namespace bvm {
    /**
     * Parses an executable or object file into memory.
     * @param stream An input stream to be read byte-for-byte.
     * @return An in-memory representation of the parsed code.
     */ 
    Object *parseBinary(std::istream& stream);
}

#endif