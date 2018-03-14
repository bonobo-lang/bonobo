#ifndef BONOBO_STRING_H
#define BONOBO_STRING_H
#include <stdint.h>
#include <stdlib.h>

/**
 * The runtime implementation of a Bonobo string.
 */
typedef struct {
    const char* data;
    uint64_t length;
    String* next;
} String;

/**
 * String "constructor".
 */
String* String_new(const char*);

void String_destroy(String*);

//String* String_concat(String*, String*);

#endif