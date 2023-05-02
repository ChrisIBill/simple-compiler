#include <stdio.h>
#include "uthash.h"
#define YYDEBUG 0
#ifdef YYDEBUG
#define printd(level, x) (level <= YYDEBUG) ? 0 : printf(x)
#else
#define printd(level, x)
#endif
#define MAXCHILDREN 3

enum LOG_LEVEL {
    LOG_DEBUG,
    LOG_INFO,
    LOG_WARN,
    LOG_ERROR,
    LOG_FATAL
};


typedef enum NodeType {
    programNodeType,
    declarationNodeType,
    stmtSeqNodeType,
    stmtNodeType,
    assignmentNodeType,
    ifElseNodeType,
    ifNodeType,
    elseNodeType,
    whileNodeType,
    writeIntNodeType,
    exprNodeType,
    simpExprNodeType,
    termNodeType,
    factorNodeType,
} NodeType;

typedef enum NodeLeafTypes {
    identLeafType,
    intLeafType,
    boolLeafType,
} NodeLeafTypes;

/* typedef enum NodeType {
    branch,
    leaf,
} NodeType; */
typedef struct programNode programNode;
typedef struct stmtSeqNode stmtSeqNode;
typedef struct declarationNode declarationNode;
typedef struct ParseTreeNode ParseTreeNode;

typedef struct symbol
{
    char* name;
    int type;
    void* value;
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
    typeStmtSeq,
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
} ifNode;

typedef struct
{
    ifNode* ifNode;
    elseNode* elseNode;
} ifElseNode;
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

typedef struct stmtSeqNode
{
    void* stmtSeq;
} stmtSeqNode;

struct declarationNode
{
    char* name;
    factorTypes type;
};

struct programNode
{
    declarationNode* declarations;
    stmtSeqNode* stmtSeq;
};

struct symbol* lookUp(char* s);
struct symbol* insert(char* st);
int handleDeclarations(declarationNode* node, FILE* out);
void handleStatement(stmtNode* node, FILE* out);
void handleStatementSeq(stmtSeqNode* node, FILE* out);
void handleAssignment(assignmentNode* node, FILE* out);
void handleIf(ifNode* node, FILE* out);
void handleElse(elseNode* node, FILE* out);
void handleWhile(whileNode* node, FILE* out);
void handleWriteInt(writeIntNode* node, FILE* out);
void handleExpression(exprNode* node, FILE* out);
void handleSimpExpr(simpExprNode* node, FILE* out);
void handleTerm(termNode* node, FILE* out);
void handleFactor(factorNode* node, FILE* out);

typedef union ParseTreeTokenTypes {
    char* name;
    int iValue;
} ParseTreeTokenTypes;

typedef union ParseTreeNodeTypes
{
    void* program;
    declarationNode* declarations;
    stmtNode* stmt;
    assignmentNode* assignment;
    ifElseNode* ifElse;
    ifNode* ifNode;
    elseNode* elseNode;
    whileNode* whileNode;
    writeIntNode* writeInt;
    exprNode* expression;
    simpExprNode* simpleExpression;
    termNode* term;
    factorNode* factor;
} ParseTreeNodeTypes;

typedef struct ParseTreeNode
{
    NodeType nodeType;
    ParseTreeNodeTypes* data;
    ParseTreeNode* left;
    ParseTreeNode* right;
} ParseTreeNode;

struct ParseTreeNode* createParseTreeNode(NodeType nodeType, ParseTreeNodeTypes* node, ParseTreeNode* left, ParseTreeNode* right);
//int createParseTree(NodeType nodeType, ParseTreeNode* node, ParseTreeNode* left, ParseTreeNode* right);
int compileParseTree(ParseTreeNode* tree, FILE* output);