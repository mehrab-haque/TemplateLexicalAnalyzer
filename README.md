## run command :
flex 1805001_lexer.l; g++ lex.yy.c; ./a.out 1805001_input.txt 1805001_log.txt 1805001_token.txt

## memory leak check command :
flex 1805001_lexer.l; g++ lex.yy.c;g++ -Werror -g lex.yy.c -o main.out;valgrind -s --leak-check=full ./main.out 1805001_input.txt 1805001_log.txt 1805001_token.txt