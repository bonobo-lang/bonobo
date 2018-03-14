#include "string.h"

String* String_new(const char* data) {
    return (String*) malloc(sizeof(String));
}

void String_destroy(String* ptr) {
    free(ptr);
}