compiler: scanner.l parser.y parser.h funcs.c
	bison -d parser.y && \
	flex -oscanner.lex.c scanner.l && \
	gcc -o $@ parser.tab.c parser.h scanner.lex.c funcs.c -lm