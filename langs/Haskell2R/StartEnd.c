// StartEnd.c
#include <Rts.h>

void HsStart() {
    int argc = 1;
    char* argv[] = {"ghcDll", NULL}; // argv must end with NULL

    // Initialize Haskell runtime
    char** args = argv;
    hs_init(&argc, &args);
}

void HsEnd() {
    hs_exit();
}
