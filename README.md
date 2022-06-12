flex lexer.l; g++ lex.yy.c; ./a.out sample_input4.txt log.txt tokens.txt

flex state.l; g++ lex.yy.c; ./a.out state.txt

flex test.l; g++ lex.yy.c; ./a.out

g++ -Werror -g lex.yy.c -o main.out
valgrind -s --leak-check=full ./main.out sample_input4.txt log.txt tokens.txt