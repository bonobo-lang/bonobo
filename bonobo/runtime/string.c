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

int String_print(String* ptr) {
    int result = -1;

    while (ptr != NULL) {
        if ((result = printf("%s", ptr->data)) < 0)
            break;
        ptr = ptr->next;
    }

    if (result > 0)
        printf("\n");

    return result;
}