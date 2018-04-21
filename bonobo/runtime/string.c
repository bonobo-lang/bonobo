#include "string.h"

String* String_new(const char* data) {
    String* ptr = (String*) malloc(sizeof(String));
    ptr->data = data;
    ptr->next = NULL;
    return ptr;
}

void String_destroy(String* ptr) {
    free(ptr);
}

const char* String_print(const char* ptr) {
    printf("%s\n", ptr);
    return ptr;
}