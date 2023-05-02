%option noyywrap nodefault yylineno

%{
   #include <string.h>
   #include "parser.h"
   #include "parser.tab.h"

   void yyerror(const char* const s) {
    fprintf(stderr, "Error | Line: %d\n%s", yylineno, s);
}
%}

%%

[1-9][0-9]*|0   {yylval.iValue = atol(yytext); /* printd(LOG_INFO, ("INFO: SCANNED TOKEN NUM_LIT: %d\n", yylval.iValue)); */ return NUM_LIT;}
false|true  {yylval.iValue = strcmp(yytext, "true"); /* printd(LOG_INFO, ("INFO: SCANNED TOKEN BOOL_LIT: %d \n", yylval.iValue)); */ return BOOL_LIT;}
[A-Z][A-Z0-9]*  {yylval.sValue = strdup(yytext); /* printf("TOKEN IDENTITY: %s\n", yylval.sValue); */ return IDENTITY;}

\(        {printd(LOG_INFO, "INFO: SCANNED TOKEN LP"); return LP;}
\)        {printf("TOKEN RP"); return RP;}
\:=      {printf("TOKEN Assignment \n"); return ASGN;}
\;        {printf("TOKEN SC\n"); return SC;}
\*|div|mod       {yylval.sValue = strdup(yytext); printf("TOKEN OP2\n"); return OP2;}
\+|-       {yylval.sValue = strdup(yytext); printf("TOKEN OP3\n"); return OP3;}
\=|!=|<|>|<=|>=       {yylval.sValue = strdup(yytext); printf("TOKEN OP4\n"); return OP4;}

if        {printf("TOKEN IF\n"); return IF;}
then      {printf("TOKEN THEN\n"); return THEN;}
else      {printf("TOKEN ELSE\n"); return ELSE;}
begin     {printf("TOKEN Begin \n");return BEGN;}
end       {printf("TOKEN END\n");return END;}
while     {printf("TOKEN WHILE\n");return WHILE;}
do        {printf("TOKEN DO\n");return DO;}
program   {printd(LOG_INFO, "INFO: TOKEN PROGRAM\n");return PROGRAM;}
var       {printf("TOKEN VAR\n");return VAR;}
" as"        {printf("TOKEN AS\n");return AS;}
int       {printf("TOKEN INT\n");return INT;}
bool      {printf("TOKEN BOOL\n");return BOOL;}

writeInt  {printf("TOKEN writeInt"); return WRITEINT;}
readInt   {printf("TOKEN readInt \n"); return READINT;}
[ \t]+ { /* ignore whitespace */}
\n        { /* ignore newlines */ }
.        {printf("TOKEN UNKNOWN\n"); return UNKNOWN;}
%%