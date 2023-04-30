%option noyywrap nodefault yylineno

%{
   #include <string.h>
   #include "parser.h"
   #include "parser.tab.h"
%}

%%

[1-9][0-9]*|0   {yylval.iValue = atol(yytext); return NUM_LIT;}
false|true  {yylval.iValue = strcmp(yytext, "true"); return BOOL_LIT;}
[A-Z][A-Z0-9]*  {yylval.sValue = strdup(yytext); return IDENTITY;}

\(        {return LP;}
\)        {return RP;}
\:=      {/* printf("Assignment \n"); */return ASGN;}
\;        {/* printf("here"); */return SC;}
\*|div|mod       {yylval.sValue = strdup(yytext); return OP2;}
\+|-       {yylval.sValue = strdup(yytext); return OP3;}
\=|!=|<|>|<=|>=       {yylval.sValue = strdup(yytext); return OP4;}

if        {return IF;}
then      {return THEN;}
else      {return ELSE;}
begin     {printf("here");return BEGN;}
end       {return END;}
while     {return WHILE;}
do        {return DO;}
program   {return PROGRAM;}
var       {return VAR;}
as        {return AS;}
int       {return INT;}
bool      {return BOOL;}

writeInt  {return WRITEINT;}
readInt   {/* printf("readInt \n"); */return READINT;}
[ \t\n]+ { /* ignore whitespace */}
.        { printf("Mystery character %c\n", *yytext); }  
%%