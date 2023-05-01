%error-verbose
%{
#include <stdio.h>
#include <string.h>
#include "parser.h"
#define YYDEBUG 1
extern int yylex();

int numDeclarations = 0;
%}

%union {
    int iValue;
    char* sValue;
    void* node;
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

%type<node> program
%type<node> declarations
%type<iValue> type
%type<node> statementSequence
%type<node> statement
%type<node> assignment
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
    handleDeclarations((declarationsNode*)$2);
    handleStatementSeq((stmtSeqNode *) $4);
    printf("finished\n");
}
;
declarations : VAR IDENTITY AS type SC declarations
{
    printf("Declaration %s\n", $2);
    numDeclarations++;
    declarationsNode* node;
    node = malloc(sizeof(declarationsNode));
    node->name = strdup($2);
    node->type = $4;
    node->next = $6;
    $$ = node;
    symbol* sym = lookUp(node->name);
    if (sym != NULL) {
        printf("Error: Variable %s already declared\n", node->name);
        exit(1);
    }
    sym = insert(node->name);
    sym->type = node->type;
}
| /* empty */ { $$ = (declarationsNode*)NULL; };
type: INT{ $$ = factorTypeInt; } | BOOL { $$ = factorTypeBool; };
statementSequence: statement statementSequence
{
    printf("Statement\n");
    stmtSeqNode* node;
    node = malloc(sizeof(stmtSeqNode));
    node->stmt = $1;
    node->next = $2;
    $$ = node;
};
| /* empty */ { $$ = (stmtSeqNode*)NULL; };
statement: assignment SC
{
    printf("Assignment\n");
    stmtNode* node;
    node = malloc(sizeof(stmtNode));
    node->type = stmtTypeAssignment;
    node->stmtPtr = (void *) $1;
    $$ = node;
}
 | ifStatement
{
    printf("If Statement\n");
    stmtNode* node;
    node = malloc(sizeof(stmtNode));
    node->type = stmtTypeIf;
    node->stmtPtr = (void *) $1;
    $$ = node;
 } | whileStatement
{
    printf("While Statement\n");
    stmtNode* node;
    node = malloc(sizeof(stmtNode));
    node->type = stmtTypeWhile;
    node->stmtPtr = (void *) $1;
    $$ = node;
 } | writeInt
 {
    printf("WriteInt Statement\n");
    stmtNode* node;
    node = malloc(sizeof(stmtNode));
    node->type = stmtTypeWriteInt;
    node->stmtPtr = (void *) $1;
    $$ = node;
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
    $$ = node;

    symbol *sym = lookUp(node->name);
    if (sym == NULL) {
        printf("Error: Variable %s not declared\n", node->name);
        exit(1);
    }
}
| IDENTITY ASGN READINT
{
    printf("ReadInt Assignment\n");
    assignmentNode* node;
    node = malloc(sizeof(assignmentNode));
    node->name = strdup($1);
    node->expr = NULL;
    $$ = node;

    symbol *sym = lookUp(node->name);
    if (sym == NULL) {
        printf("Error: Variable %s not declared\n", node->name);
        exit(1);
    }
    if (sym->type != factorTypeInt) {
        printf("Error: Variable %s is of type %s, but READINT requires type int\n", node->name, sym->type);
        exit(1);
    }
};
ifStatement: IF expression THEN statementSequence elseClause END SC
{
    ifNode *node;
    node = malloc(sizeof(ifNode));
    node->expr = $2;
    node->stmtSeq = $4;
    node->elseNode = $5;
    $$ = node;
};
elseClause: ELSE statementSequence
{
    elseNode *node;
    node = malloc(sizeof(elseNode));
    node->stmtSeq = $2;
    $$ = node;
}
| /* empty */ { $$ = (elseNode*)NULL; };
whileStatement: WHILE expression DO statementSequence END SC
{
    whileNode *node;
    node = malloc(sizeof(whileNode));
    node->expr = $2;
    node->stmtSeq = $4;
    $$ = node;
};
writeInt: WRITEINT expression SC
{
    writeIntNode *node;
    node = malloc(sizeof(writeIntNode));
    node->expr = $2;
    $$ = node;
};
expression: simpleExpression 
{
    printf("Single Expression\n");
    exprNode* node;
    node = malloc(sizeof(exprNode));
    node->simpExpr1 = (void *) $1;
    $$ = node;
}
| simpleExpression OP4 simpleExpression
{
    printf("Double Expression\n");
    exprNode* node;
    node = malloc(sizeof(exprNode));
    node->simpExpr1 = (void *) $1;
    node->op = $2;
    node->simpExpr2 = (void *) $3;
    $$ = node;
};
simpleExpression: term 
{
    printf("Single Term\n");
    simpExprNode* node;
    node = malloc(sizeof(exprNode));
    node->term1 = (void *) $1;
    node->term2 = (void *) NULL;
    $$ = node;
}
| term OP3 term
{
    printf("Double Term\n");
    simpExprNode* node;
    node = malloc(sizeof(exprNode));
    node->term1 = (void *) $1;
    node->op = $2;
    node->term2 = (void *) $3;
    $$ = node;
};
term: factor
{
    printf("Single Factor\n");
    termNode* node;
    node = malloc(sizeof(termNode));
    node->factor1 = (void*)$1;
    node->factor2 = (void*)NULL;
    //Print the factor
    $$ = node;
}
 | factor OP2 factor
{
    printf("Double Factor\n");
    termNode* node;
    node = malloc(sizeof(termNode));
    node->factor1 = (void *) $1;
    node->op = $2;
    node->factor2 = (void *) $3;
    $$ = node;
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
    fn->type = factorTypeInt;
    fn->value = vn;
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
    printf("Closing\n");
    $$ = fn;
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
    $$ = fn;
}
;

%%

// Epilogue
int main(argc, argv)
int argc;
char** argv;
{
    extern FILE *yyin;
    ++argv, --argc;
    if(argc > 0) {
        yyin = fopen(argv[0], "r");

        if (yyin == NULL) {
            printf("Error: File %s not found\n", argv[0]);
            exit(1);
        }
    }
    else {
        yyin = stdin;
    }
    return yyparse();
}
int yywrap()
{
    return (1);
}