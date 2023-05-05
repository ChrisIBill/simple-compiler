%option noyywrap nodefault yylineno

%{
   #include <string.h>
   #include "parser.h"
   #include "parser.tab.h"

   void yyerror(const char* const s) {
    fprintf(stderr, "Error | Line: %d\n%s\n", yylineno, s);
}
%}

%%

[1-9][0-9]*|0   {yylval.iValue = atol(yytext); /* printd(LOG_DATA, ("INFO: SCANNED TOKEN NUM_LIT: %d\n", yylval.iValue)); */ return NUM_LIT;}
false|true  {yylval.iValue = strcmp(yytext, "true"); /* printd(LOG_DATA, ("INFO: SCANNED TOKEN BOOL_LIT: %d \n", yylval.iValue)); */ return BOOL_LIT;}
[A-Z][A-Z0-9]*  {yylval.sValue = strdup(yytext); /* printf("TOKEN IDENTITY: %s\n", yylval.sValue); */ return IDENTITY;}

\(                  {printd(LOG_DATA, "INFO: SCANNED TOKEN LP\n"); return LP;}
\)                  {printd(LOG_DATA, "INFO: SCANNED TOKEN RP\n"); return RP;}
\:=                 {printd(LOG_DATA, "INFO: SCANNED TOKEN ASSIGN\n"); return ASGN;}
\;                  {printd(LOG_DATA, "INFO: SCANNED TOKEN SC\n"); return SC;}
\*|div|mod          {yylval.sValue = strdup(yytext); printd(LOG_DATA, "INFO: SCANNED TOKEN OP2\n"); return OP2;}
\+|-                {yylval.sValue = strdup(yytext); printd(LOG_DATA, "INFO: SCANNED TOKEN OP3\n"); return OP3;}
\=|!=|<|>|<=|>=     {yylval.sValue = strdup(yytext); printd(LOG_DATA, "INFO: SCANNED TOKEN OP4\n"); return OP4;}

if                  {printd(LOG_DATA, "INFO: SCANNED TOKEN IF\n"); return IF;}
then                {printd(LOG_DATA, "INFO: SCANNED TOKEN THEN\n"); return THEN;}
else                {printd(LOG_DATA, "INFO: SCANNED TOKEN ELSE\n"); return ELSE;}
begin               {printd(LOG_DATA, "INFO: SCANNED TOKEN BEGIN\n");return BEGN;}
end                 {printd(LOG_DATA, "INFO: SCANNED TOKEN END\n");return END;}
while               {printd(LOG_DATA, "INFO: SCANNED TOKEN WHILE\n");return WHILE;}
do                  {printd(LOG_DATA, "INFO: SCANNED TOKEN DO\n");return DO;}
program             {printd(LOG_DATA, "INFO: TOKEN PROGRAM\n");return PROGRAM;}
var                 {printd(LOG_DATA, "INFO: SCANNED TOKEN VAR\n");return VAR;}
" as"               {printd(LOG_DATA, "INFO: SCANNED TOKEN AS\n");return AS;}
int                 {printd(LOG_DATA, "INFO: SCANNED TOKEN INT\n");return INT;}
bool                {printd(LOG_DATA, "INFO: SCANNED TOKEN BOOL\n");return BOOL;}

writeInt            {printd(LOG_DATA, "INFO: SCANNED TOKEN WRITEINT\n"); return WRITEINT;}
readInt             {printd(LOG_DATA, "INFO: SCANNED TOKEN READINT\n"); return READINT;}
[ \t]+              { /* ignore whitespace */}
\n                  { /* ignore newlines */ }
.                   {printd(LOG_WARN, "WARN: SCANNED UNKNOWN TOKEN\n"); return UNKNOWN;}
%%