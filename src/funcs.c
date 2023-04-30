#include "uthash.h"
#include "parser.h"

struct symbol symbolTable = NULL;

struct parseTree {
    int        /* makes this structure hashable */
};

struct symbol* lookUp(char* s) {
    struct symbol* symbol;
    HASH_FIND_STR(symbolTable, s, symbol);
    if (symbol == NULL) {
        symbol = (struct symbol*)malloc(sizeof * symbol);
        strcpy(symbol->name, s);
        HASH_ADD_STR(symbolTable, symbol->name, symbol);
    }
    return symbol;
}

