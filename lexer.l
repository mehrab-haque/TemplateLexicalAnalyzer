%option noyywrap

%{
#include<iostream>
#include<cstdio>
#include<cstring>
#include "SymbolTable.h"

using namespace std;

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

[0-9]+ {
    //integer constant
    fprintf(logFile,"Line no %d: Token <CONST_INT> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<CONST_INT, %s> ",yytext);
}

\n {lineCount++;}
%%
  

int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    logFile=fopen(argv[2], "w");
    tokenFile=fopen(argv[3], "w");
    yylex();
    fclose(yyin);
    fclose(logFile);
    fclose(tokenFile);
    return 0;
}