#include "string.h"

String* String_new(const char* data) {
    String* ptr = (String*) malloc(sizeof(String));
    ptr->next = NULL;
    return ptr;
}

void String_destroy(String* ptr) {
    free(ptr);
}

int String_print(String* ptr) {
    int result;

    do {
        result = printf("%s", ptr->data);
        ptr = ptr->next;
    } while (result == 0 && ptr != NULL);

    if (result == 0)
        printf("\n");

    return result;
}