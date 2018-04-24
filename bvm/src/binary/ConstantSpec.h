#ifndef BVM_CONSTANTSPEC_H
#define BVM_CONSTANTSPEC_H

namespace bvm {
  typedef struct {
    public:
      const char* name;
      unsigned int size;
  } ConstantSpec;
}

#endif
