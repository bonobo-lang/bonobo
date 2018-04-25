#ifndef BVM_BVMEXECUTABLE_H
#define BVM_BVMEXECUTABLE_H
#include <stdint.h>
#include "Constant.h"
#include "Function.h"
#include "Type.h"

namespace bvm {
  typedef struct {
    Constant *constants;
    Type* types;
    Function* functions;
    int64_t number_of_constants, number_of_types, number_of_functions;
  } Object;
}

#endif
