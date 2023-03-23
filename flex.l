%{
   #include "bison.tab.h"
/* #include <string>
#include <tuple>
#include <math.h>
int numLines = 0, numChars = 0, numTokens = 0; */
%}

%%
[1-9][0-9]*|0   {return NUM_LIT;}
false|true  {return BOOL_LIT;}
[A-Z][A-Z0-9]*  {return IDENTITY;}

\(        {return LP;}
\)        {return RP;}
\:=      {/* printf("Assignment \n"); */return ASGN;}
\;        {/* printf("here"); */return SC;}
\*|div|mod       {return OP2;}
\+|-       {return OP3;}
\=|!=|<|>|<=|>=       {/* printf("reading OP4\n"); */ return OP4;}

if        {return IF;}
then      {return THEN;}
else      {return ELSE;}
begin     {return BEGN;}
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
%%