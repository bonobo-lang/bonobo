#ifndef BVM_BVMEXECUTABLE_H
#define BVM_BVMEXECUTABLE_H
#include "ConstantSpec.h"
#include "FunctionSpec.h"
#include "TypeSpec.h"

namespace bvm {
  typedef struct {
    ConstantSpec *constants;
    TypeSpec* types;
    FunctionSpec* functions;
    int number_of_constants, number_of_types, number_of_functions;
  } BVMExecutable;
}

#endif
