#ifndef BONOBO_STRING_H
#define BONOBO_STRING_H
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>


/**
 * The runtime implementation of a Bonobo string.
 */
typedef struct bonobo_String {
    const char* data;
    uint64_t length;
    struct bonobo_String* next;
} String;

void String_destroy(String*);

String* String_new(const char*);

const char* String_print(const char*);

#endif