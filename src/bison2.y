% {
#include <stdio.h>

    /* prototypes */
    nodeType
        %}
% union {
    int iValue;
    char sIndex;
    std::string* sValue;
}
% token <iValue> NUM_LIT
% token <iValue> BOOL_LIT
% token <sValue> IDENTITY
% token LP RP ASGN SC
% left OP2 OP3
% token OP4
% token IF THEN ELSE BEGN END WHILE DO PROGRAM VAR AS INT BOOL
% token WRITEINT READINT

%%
program : PROGRAM declarations BEGN statementSequence END
{
    printf("Program Valid\n");
};
declarations: decl | declarations decl;
decl: VAR IDENTITY AS type SC;
type: INT | BOOL;
statementSequence: statement | statementSequence statement;
statement: assignment | ifStatement | whileStatement | writeInt;
assignment: IDENTITY ASGN expression SC | IDENTITY ASGN READINT SC;
ifStatement: IF expression THEN statementSequence elseClause END SC;
elseClause: /* empty */ | ELSE statementSequence;
whileStatement: WHILE expression DO statementSequence END SC;
writeInt: WRITEINT expression SC;
expression: simpleExpression | simpleExpression OP4 simpleExpression;
simpleExpression: term | term OP3 term;
term: factor | factor OP2 factor;
factor: IDENTITY | NUM_LIT | BOOL_LIT;

%%

// Epilogue
main(argc, argv)
int argc;
char** argv;
{
    extern FILE* yyin;
    ++argv, --argc;
    if (argc > 0) {
        yyin = fopen(argv[0], "r");
    }
    else {
        yyin = stdin;
    }

    yyparse();
}
yyerror(char* s)
{
    fprintf(stderr, "%s\n", s);
}
yywrap()
{
    return (1);
}