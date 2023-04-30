#define MAXCHILDREN 3

void yyerror(char* s);

int yyparse();
int yylex();

struct symbol
{
    char* name;
    int type;
    int value;
    int isInitialized;
    UT_hash_handle hh;
};

struct symbol* lookUp(char* s);


/* Enums */

typedef enum
{
    typeInt,
    typeBool
} typeNodeEnum;

typedef enum
{
    typeDecl,
    typeDeclarations
} declarationsNodeEnum;

typedef enum
{
    typeExpr,
    typeReadInt
} assignmentNodeEnum;

typedef enum
{
    typeAssignment,
    typeIf,
    typeWhile,
    typeWriteInt,
} stmtNodeEnum;

typedef enum
{
    typeStmt,
    typeStmtSeq
} stmtSeqNodeEnum;

typedef enum
{
    typeDeclarations,
    typeStmtSeq
} nodeEnum;
/* Structs */
struct
{
    declarationsNodeEnum type;
    char* name;
    typeNodeEnum typeVal;
    union
    {
        int intVal;
        int boolVal;
    } value;
} declNodeType;

struct
{
    declarationsNodeEnum type;

    union
    {
        declarationsNodeType* declarations;
        declNodeType* decl;
    } value;
    struct declarationsNodeType* next;
} declarationsNodeType;

typedef struct
{
    char* name;
    typeNodeEnum type;
    int value;
} idNodeType;

typedef union
{
    idNodeType* id;
    int num;
    int boolVal;
    exprNodeType* expr;
} factorNodeType;

typedef struct
{
    /* TODO */
    factorNodeType* factor1;
    union factorNodeType* factor2;
} termNodeType;

typedef struct
{
    termNodeType* term1;
    union termNodeType* term2;
} simpExprNodeType;

typedef struct
{
    simpExprNodeType* simpExpr1;
    union simpExprNodeType* simpExpr2;
} exprNodeType;

typedef struct
{
    stmtSeqNodeType* stmtSeq;
} elseNodeType;

typedef struct
{
    exprNodeType* expr;
    stmtSeqNodeType* stmtSeq;
} whileNodeType;

typedef struct
{
    exprNodeType* expr;
    stmtSeqNodeType* stmtSeq;
    elseNodeType* elseNode;
} ifNodeType;

typedef struct
{
    char* name;
    assignmentNodeEnum type;
    int value;
} assignmentNodeType;

typedef union
{
    assignmentNodeType* assignment;
    ifNodeType* ifNode;
    whileNodeType* whileNode;
    writeIntNodeType* writeInt;
} stmtNodeType;

typedef struct
{
    stmtSeqNodeEnum type;
    union
    {
        stmtSeqNodeType* stmtSeq;
        stmtNodeType* stmt;
    } subkind;
    struct stmtSeqNodeType* next;
} stmtSeqNodeType;

typedef struct
{
    declarationsNodeType* declarations;
    stmtSeqNodeType* stmtSeq;
    NodeType nodeEnum;
} programNodeType;

typedef struct
{

}
// struct parseTreeNode* child[MAXCHILDREN];
    // struct parseTreeNode* sibling; /* points to next sibling of node */

    // NodeType nodeEnum;
    // union
    // {
    //     /* Should only need these two in union, all other nodes of tree are either these, or children of these */
    //     declarationsNodeType declarations;
    //     stmtSeqNodeType stmtSeq;
    //     /* Some of the subtypes of these nodes */
    //     // declNodeType decl;
    //     // typeNodeEnum type;
    //     // stmtNodeType stmt;
    //     // assignmentNodeType assignment;
    //     // exprNodeType expr;
    //     // simpExprNodeType simpExpr;
    //     // termNodeType term;
    // } subtype;

    // union
    // {
    //     int op; /* value for type of operator */
    //     int val;
    //     std::string* name; /* name for identifier */
    // };

} parseTreeNode;

struct parseTreeNode* newDeclNode(declarationsNodeEnum type, char* name, typeNodeEnum typeVal, int value);