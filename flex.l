%{
#include <vector>
#include <iostream>
#include <string>
#include <tuple>
#include <math.h>
int numLines = 0, numChars = 0, numTokens = 0;
typedef std::vector<std::tuple<std::string, std::string>> lexicalVector;
lexicalVector lv;
%}

NUM_LIT     [1-9][0-9]*|0
BOOL_LIT    false|true
IDENTITY    [A-Z][A-Z0-9]*

LP          \(
RP          \)
ASGN        :=
SC          \;
OP2         \*|div|mod
OP3         \+|-
OP4         =|!=|<|>|<=|>=

IF          if
THEN        then
ELSE        else
BEGIN       begin
END         end
WHILE       while
DO          do
PROGRAM     program
VAR         var
AS          as
INT         int
BOOL        bool

WRITEINT    writeInt
READINT     readInt
%%
{NUM_LIT}   numTokens++; lv.push_back(std::tuple<std::string, std::string> ("num", yytext));
{BOOL_LIT}  numTokens++; lv.push_back(std::tuple<std::string, std::string> ("boollit", yytext));
{IDENTITY}  numTokens++; lv.push_back(std::tuple<std::string, std::string> ("ident", yytext));

{LP}        numTokens++; lv.push_back(std::tuple<std::string, std::string> ("LP", yytext));
{RP}        numTokens++; lv.push_back(std::tuple<std::string, std::string> ("RP", yytext));
{ASGN}      numTokens++; lv.push_back(std::tuple<std::string, std::string> ("ASGN", yytext));
{SC}        numTokens++; lv.push_back(std::tuple<std::string, std::string> ("SC", yytext));
{OP2}       numTokens++; lv.push_back(std::tuple<std::string, std::string> ("OP2", yytext));
{OP3}       numTokens++; lv.push_back(std::tuple<std::string, std::string> ("OP3", yytext));
{OP4}       numTokens++; lv.push_back(std::tuple<std::string, std::string> ("OP4", yytext));

{IF}        numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{THEN}      numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{ELSE}      numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{BEGIN}     numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{END}       numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{WHILE}     numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{DO}        numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{PROGRAM}   numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{VAR}       numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{AS}        numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{INT}       numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));
{BOOL}      numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Keyword", yytext));

{WRITEINT}  numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Built-in Procedure", yytext));
{READINT}   numTokens++; lv.push_back(std::tuple<std::string, std::string> ("Built-in Procedure", yytext));
\n numLines++; numChars++;
. numChars++;
%%

int yywrap(){}
int main (int argc, char **argv) {
    yylex();
    printf("number of lines = %d, number of chars = %d, number of tokens = %d\n", numLines, numChars, numTokens );
    for(lexicalVector::const_iterator i = lv.begin(); i != lv.end(); i++) {
        std::cout << "Lexeme: " << (std::get<0>(*i));
        std::cout << "  Token: " << (std::get<1>(*i)) << std::endl;
    }
    /* for(auto i = lexVec.begin(); i != lexVec.end(); i++) {
        int j = i;
         std::cout << lexVec.at(j) << std::endl;
     } */
return 0;
    /* yylex();
    printf("# of lines is %d, # of chars is %d \n", numLines, numChars);
    return 0; */
}

/* 
program
   var SMALLER as int ;
   var BIGGER as int ;
   var TEMP as int ;
begin
   BIGGER := readInt ;
   SMALLER := readInt ;

   if SMALLER > BIGGER then
      TEMP := SMALLER ;
      TEMP1 := 2147483648 ;
      SMALLER := BIGGER ;
      BIGGER := TEMP ;
   end ;

   while SMALLER > 0 do
      BIGGER := BIGGER - SMALLER ;

      if SMALLER > BIGGER then
         TEMP := SMALLER ;
         SMALLER := BIGGER ;
         BIGGER := TEMP ;
      end ;
   end ;
   writeInt BIGGER ;
end
*/