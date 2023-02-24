%{
int numLines = 0, numChars = 0;
%}
%%
\n numLines++; numChars++;
. numChars++;
%%
int yywrap(){};
int main () {
    yylex();
    printf("# of lines is %d, # of chars is %d \n", numLines, numChars);
    return 0;
}