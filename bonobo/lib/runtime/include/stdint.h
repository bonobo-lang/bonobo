/* stdint.h */

#ifdef __TINYC__
/* tcc */
#include <stddef.h>
#else
/* assume gcc */
#include_next <stdint.h>
#endif