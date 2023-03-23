parser: flex.l bison.y
	bison -d bison.y
	flex flex.l
	cc -o $@ bison.tab.c lex.yy.c -lfl
