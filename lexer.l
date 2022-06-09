%{
#include <stdio.h>
#include<string.h>

int lineCount=1;
FILE *logFile,*tokenFile;
%}
  
%%
(if|for|do|int|float|void|switch|default|else|while|break|char|double|return|case|continue) {
    //keywords
    char *upperCaseKeyword=(char*)malloc(sizeof(char*)*strlen(yytext));
    int i;
    for(i=0;i<strlen(yytext);i++)
        upperCaseKeyword[i]=yytext[i]-32;
    fprintf(logFile, "Line no %d: Token<%s> Lexeme %s found\n\n",lineCount,upperCaseKeyword,yytext);
    fprintf(tokenFile,"<%s> ",upperCaseKeyword);
    free(upperCaseKeyword);
}

\n {lineCount++;}
%%
  
int yywrap(){}

int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    logFile=fopen(argv[2], "w");
    tokenFile=fopen(argv[3], "w");
    yylex();
    //fprintf(logFile,"lines  %d", linecount);
    fclose(yyin);
    fclose(logFile);
    fclose(tokenFile);
    return 0;
}