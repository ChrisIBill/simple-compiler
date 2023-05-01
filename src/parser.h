#include "uthash.h"
#define MAXCHILDREN 3

typedef enum NodeTypes {
    programNodeType,
    declarationsNodeType,
    stmtSeqNodeType,
    stmtNodeType,
    assignmentNodeType,
    ifNodeType,
    elseNodeType,
    whileNodeType,
    writeIntNodeType,
    exprNodeType,
    simpExprNodeType,
    termNodeType,
    factorNodeType,
} NodeType;

typedef struct stmtSeqNode stmtSeqNode;
typedef struct declarationsNode declarationsNode;
typedef struct symbol
{
    char* name;
    int type;
    int value;
    int isInitialized;
    UT_hash_handle hh;
} symbol;

/* Enums */

typedef enum
{
    factorTypeIdent,
    factorTypeInt,
    factorTypeBool
} factorTypes;

typedef enum
{
    stmtTypeAssignment,
    stmtTypeIf,
    stmtTypeWhile,
    stmtTypeWriteInt,
} stmtTypes;

typedef enum
{
    typeStmt,
    typeStmtSeq
} stmtSeqNodeEnum;
/* Structs */
typedef union valueNode {
    char* name;
    int iValue;
} valueNode;

typedef struct
{
    factorTypes type;
    valueNode* value;
} factorNode;

typedef struct
{
    factorNode* factor1;
    factorNode* factor2;
    char* op;
} termNode;

typedef struct
{
    termNode* term1;
    termNode* term2;
    char* op;
} simpExprNode;

typedef struct
{
    simpExprNode* simpExpr1;
    simpExprNode* simpExpr2;
    char* op;
} exprNode;

typedef struct
{
    exprNode* expr;
} writeIntNode;

typedef struct
{
    stmtSeqNode* stmtSeq;
} elseNode;

typedef struct
{
    exprNode* expr;
    stmtSeqNode* stmtSeq;
} whileNode;

typedef struct
{
    exprNode* expr;
    stmtSeqNode* stmtSeq;
    elseNode* elseNode;
} ifNode;

typedef struct
{
    char* name;
    exprNode* expr;
} assignmentNode;

typedef struct
{
    stmtTypes type;
    void* stmtPtr;
} stmtNode;

struct stmtSeqNode
{
    stmtNode* stmt;
    stmtSeqNode* next;
};

struct declarationsNode
{
    char* name;
    factorTypes type;
    declarationsNode* next;
};

struct programNode
{
    declarationsNode* declarations;
    stmtSeqNode* stmtSeq;
    //NodeType nodeEnum;
};

struct symbol* lookUp(char* s);
struct symbol* insert(char* st);
void handleDeclarations(declarationsNode* node);
void handleStatement(stmtNode* node);
void handleStatementSeq(stmtSeqNode* node);
void handleAssignment(assignmentNode* node);
void handleIf(ifNode* node);
void handleElse(elseNode* node);
void handleWhile(whileNode* node);
void handleWriteInt(writeIntNode* node);
void handleExpression(exprNode* node);
void handleSimpExpr(simpExprNode* node);
void handleTerm(termNode* node);
void handleFactor(factorNode* node);

typedef union parseTreeNodeType
{
    programNode* program;
    declarationsNode* declarations;
    stmtSeqNode* stmtSeq;
    stmtNode* stmt;
    assignmentNode* assignment;
    ifNode* ifNode;
    elseNode* elseNode;
    whileNode* whileNode;
    writeIntNode* writeInt;
    exprNode* expression;
    simpExprNode* simpleExpression;
    termNode* term;
    factorNode* factor;
} parseTreeNodeType;

typedef struct ParseTreeNode
{
    NodeType nodeType;
    parseTreeNode* nodeData;
    int numChildren;
    struct parseTreeNode* left;
    struct parseTreeNode* right;
} ParseTreeNode;

int createParseTreeNode()
int createParseTree(NodeType nodeType, ParseTreeNode* node, ParseTreeNode* left, ParseTreeNode* right);
void compileParseTree(ParseTreeNode* tree);