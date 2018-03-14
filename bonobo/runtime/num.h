#ifndef BONOBO_NUM_H
#define BONOBO_NUM_H
#include <stdint.h>

/**
 * The runtime implementation of a Bonobo Num.
 */
typedef struct bonobo_Num {
    struct bonobo_Num* next;
} Num;

#endif