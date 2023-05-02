%error-verbose
%{
#include <string.h>
#include "parser.h"
#define YYDEBUG 1
/* DEBUG */

extern int yylex();

int numDeclarations = 0;

struct ParseTreeNode* ROOT = (ParseTreeNode*)NULL;
FILE* outFile;
%}

%locations

%union {
    int iValue;
    char* sValue;
    ParseTreeNode* node;
}

%start program
%token <iValue> NUM_LIT
%token <iValue> BOOL_LIT
%token <sValue> IDENTITY
%token LP RP ASGN SC
%token <sValue> OP2
%token <sValue> OP3
%token <sValue> OP4
%token IF THEN ELSE BEGN END WHILE DO PROGRAM VAR AS INT BOOL
%token WRITEINT READINT
%token UNKNOWN

%type<node> program
%type<node> declarations
%type<iValue> type
%type<node> statementSequence
%type<node> statement
%type<node> assignment
%type<node> ifElseStatement
%type<node> ifStatement
%type<node> whileStatement
%type<node> writeInt
%type<node> elseClause
%type<node> expression
%type<node> simpleExpression
%type<node> term
%type<node> factor

%%
program : PROGRAM declarations BEGN statementSequence END
{
    printf("Program Valid\n");
    printf("finished\n");
    ROOT = createParseTreeNode(programNodeType, NULL, $2, $4);
}
;
declarations : VAR IDENTITY AS type SC declarations
{
    printf("Declaration %s\n", $2);
    numDeclarations++;
    declarationNode* node;
    node = malloc(sizeof(declarationNode));
    node->name = strdup($2);
    node->type = $4;
    $$ = createParseTreeNode(declarationNodeType, node, (declarationNode *)$6, NULL);
    symbol* sym = lookUp(node->name);
    if (sym != NULL) {
        printf("Error: Variable %s already declared\n", node->name);
        exit(1);
    }
    sym = insert(node->name);
    sym->type = node->type;
}
| /* empty */ { $$ = (declarationNode*)NULL; };
type: INT{ $$ = factorTypeInt; } | BOOL { $$ = factorTypeBool; };
statementSequence: statement SC statementSequence
{
    printf("Statement\n");
    stmtSeqNode* node;
    node = malloc(sizeof(stmtSeqNode));
    /* Left child is statement, right child is sequence or Null */
    $$ = createParseTreeNode(stmtSeqNodeType, node, (stmtNode *) $1, (stmtSeqNode *)$3);
};
| /* empty */ { $$ = (stmtSeqNode*)NULL; };
statement: assignment
{
    printf("Assignment\n");
    stmtNode* node;
    node = malloc(sizeof(stmtNode));
    printf("here\n");
    node->type = stmtTypeAssignment;
    printf("here\n");
    node->stmtPtr = (void*)$1;
    printf("here\n");
    $$ = createParseTreeNode(stmtNodeType, node, $1, NULL);
}
 | ifElseStatement
{
    printf("If Statement\n");
    stmtNode* node;
    node = malloc(sizeof(stmtNode));
    node->type = stmtTypeIf;
    node->stmtPtr = (void *) $1;
    $$ = createParseTreeNode(stmtNodeType, node, $1, NULL);
 } | whileStatement
{
    printf("While Statement\n");
    stmtNode* node;
    node = malloc(sizeof(stmtNode));
    node->type = stmtTypeWhile;
    node->stmtPtr = (void *) $1;
    $$ = createParseTreeNode(stmtNodeType, node, $1, NULL);
 } | writeInt
 {
    printf("WriteInt Statement\n");
    stmtNode* node;
    node = malloc(sizeof(stmtNode));
    node->type = stmtTypeWriteInt;
    node->stmtPtr = (void *) $1;
    $$ = createParseTreeNode(stmtNodeType, node, $1, NULL);
 };
assignment: IDENTITY ASGN expression
{
    printf("Identity Assignment\n");
    assignmentNode* node;
    node = malloc(sizeof(assignmentNode));
    node->name = strdup($1);
    printf("Assignment %s\n", node->name);
    node->expr = $3;
    printf("Read %s", (char*)$3);

    symbol *sym = lookUp(node->name);
    if (sym == NULL) {
        printf("Error: Variable %s not declared\n", node->name);
        exit(1);
    }
    /* @TODO type checking expression? */
    sym->isInitialized = 1;
    $$ = createParseTreeNode(assignmentNodeType, node, $3, NULL);
    /* @TODO value assignment, maybe we can check for constants? */
}
| IDENTITY ASGN READINT
{
    printf("ReadInt Assignment\n");
    assignmentNode* node;
    node = malloc(sizeof(assignmentNode));
    node->name = strdup($1);
    node->expr = NULL;

    symbol *sym = lookUp(node->name);
    if (sym == NULL) {
        printf("Error: Variable %s not declared\n", node->name);
        exit(1);
    }
    if (sym->type != factorTypeInt) {
        printf("Error: Variable %s is of type %s, but READINT requires type int\n", node->name, sym->type);
        exit(1);
    }
    $$ = createParseTreeNode(assignmentNodeType, node, NULL, NULL);
};
ifElseStatement: IF ifStatement elseClause END SC
{
    ifElseNode *node;
    node = malloc(sizeof(ifNode));
    node->ifNode = $2;
    node->elseNode = $3;
    /* @TODO assign null node */
    $$ = createParseTreeNode(ifElseNodeType, node, $2, $3);
};
ifStatement: expression THEN statementSequence
{
    ifNode *node;
    node = malloc(sizeof(ifNode));
    node->expr = $1;
    node->stmtSeq = $3;
    $$ = createParseTreeNode(ifNodeType, node, $1, $3);
};
elseClause: ELSE statementSequence
{
    elseNode *node;
    node = malloc(sizeof(elseNode));
    node->stmtSeq = $2;
    $$ = createParseTreeNode(elseNodeType, node, $2, NULL);
}
| /* empty */ { $$ = (elseNode*)NULL; };
whileStatement: WHILE expression DO statementSequence END
{
    whileNode *node;
    node = malloc(sizeof(whileNode));
    node->expr = $2;
    node->stmtSeq = $4;
    $$ = createParseTreeNode(whileNodeType, node, $2, $4);
};
writeInt: WRITEINT expression
{
    printf("WriteInt\n");
    writeIntNode* node;
    node = malloc(sizeof(writeIntNode));
    node->expr = $2;
    $$ = createParseTreeNode(writeIntNodeType, node, $2, NULL);
};
expression: simpleExpression 
{
    printf("Single Expression\n");
    exprNode* node;
    node = malloc(sizeof(exprNode));
    node->simpExpr1 = (void *) $1;
    $$ = createParseTreeNode(exprNodeType, node, $1, NULL);
}
| simpleExpression OP4 simpleExpression
{
    printf("Double Expression\n");
    exprNode* node;
    node = malloc(sizeof(exprNode));
    node->simpExpr1 = (void *) $1;
    node->op = $2;
    node->simpExpr2 = (void *) $3;
    $$ = createParseTreeNode(exprNodeType, node, $1, $3);
};
simpleExpression: term 
{
    printf("Single Term\n");
    simpExprNode* node;
    node = malloc(sizeof(exprNode));
    node->term1 = (void *) $1;
    node->term2 = (void *) NULL;
    $$ = createParseTreeNode(simpExprNodeType, node, $1, NULL);
}
| term OP3 term
{
    printf("Double Term\n");
    simpExprNode* node;
    node = malloc(sizeof(exprNode));
    node->term1 = (void *) $1;
    node->op = $2;
    node->term2 = (void *) $3;
    $$ = createParseTreeNode(simpExprNodeType, node, $1, $3);
};
term: factor
{
    printf("Single Factor\n");
    termNode* node;
    node = malloc(sizeof(termNode));
    node->factor1 = (void*)$1;
    node->factor2 = (void*)NULL;
    //Print the factor
    $$ = createParseTreeNode(termNodeType, node, $1, NULL);
}
 | factor OP2 factor
{
    printf("Double Factor\n");
    termNode* node;
    node = malloc(sizeof(termNode));
    node->factor1 = (void *) $1;
    node->op = $2;
    node->factor2 = (void *) $3;
    $$ = createParseTreeNode(termNodeType, node, $1, $3);
};
factor: IDENTITY
{
    printf("Identity Factor\n");
    /* @TODO */
    factorNode* fn;
    valueNode* vn;
    
    fn = malloc(sizeof(factorNode));
    vn = malloc(sizeof(valueNode));
    
    vn->name = $1;
    fn->type = factorTypeIdent;
    fn->value = vn;

    $$ = createParseTreeNode(factorNodeType, fn, NULL, NULL);
}
| NUM_LIT 
{
    printf("Num Factor\n");
    factorNode* fn;
    valueNode* vn;
    
    fn = malloc(sizeof(factorNode));
    vn = malloc(sizeof(valueNode));

    vn->iValue = $1;
    printf("Num Factor: %d\n", vn->iValue);
    fn->type = factorTypeInt;
    fn->value = vn;
    $$ = createParseTreeNode(factorNodeType, fn, NULL, NULL);
}
| BOOL_LIT 
{
    printf("Bool Factor\n");
    factorNode* fn;
    valueNode* vn;
    
    fn = malloc(sizeof(factorNode));
    vn = malloc(sizeof(valueNode));

    vn->iValue = $1;
    fn->type = factorTypeBool;
    fn->value = vn;
    $$ = createParseTreeNode(factorNodeType, fn, NULL, NULL);
}
| error { yyerrok; yyerror("Error: Invalid Factor"); }
;

%%

// Epilogue
int main(argc, argv)
int argc;
char** argv;
{
    printd(LOG_DEBUG, "DEBUG LOGGING ON\n");
    printd(LOG_INFO, "INFO LOGGING ON\n");
    printd(LOG_WARN, "WARN LOGGING ON\n");
    printd(LOG_ERROR, "ERROR LOGGING ON\n");
    printd(LOG_FATAL, "FATAL LOGGING ON\n");
    extern FILE* yyin;
    ++argv, --argc;
    if(argc > 0) {
        yyin = fopen(argv[0], "r");

        if (yyin == NULL) {
            printd(LOG_FATAL, "FATAL ERROR: File %s not found\n");
            exit(1);
        }
    }
    else {
        yyin = stdin;
    }
    int ret = yyparse();
    if (ret == 0) {
        printd(LOG_INFO, "Parse Successful\n");
        outFile = fopen("output.c", "w");
        compileParseTree(ROOT, outFile);
    }
    else {
        printd(LOG_INFO, "Parse Failed\n");
    }
}
int yywrap()
{
    return (1);
}