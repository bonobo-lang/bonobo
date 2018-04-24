#ifndef BVM_CONSTANTSPEC_H
#define BVM_CONSTANTSPEC_H

namespace bvm {
  typedef struct Constant {
    public:
      const char* name;
      uint8_t size;
      struct Constant* next = nullptr;
  } Constant;
}

#endif
