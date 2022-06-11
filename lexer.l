%option noyywrap

%x STRING
%x COMMENT_SINGLE_LINE
%x COMMENT_MULTI_LINE

%{
#include<iostream>
#include<cstdio>
#include<cstring>
#include <string>
#include "SymbolTable.h"

using namespace std;

int lineCount=1;
FILE *logFile,*tokenFile;
string stringBody;
string logStringBody;
string commentBody;
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

[0-9]*([.][0-9]+)?([eE][-+]?[0-9]+)? {
    //floating constant
    fprintf(logFile,"Line no %d: Token <CONST_FLOAT> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<CONST_FLOAT, %s> ",yytext);
}

\'.\' {
    //character constant
    fprintf(logFile,"Line no %d: Token <CONST_CHAR> Lexeme %s found  --> <CONST_CHAR, %c> \n\n",lineCount,yytext,yytext[1]);
    fprintf(tokenFile,"<CONST_CHAR, %c> ",yytext[1]);
}

[']\\[ntafrbv0\'\\]['] {
    //character constant
    char ch;
    if(yytext[2]=='n')ch='\n';
    else if(yytext[2]=='t')ch='\t';
    else if(yytext[2]=='a')ch='\a';
    else if(yytext[2]=='f')ch='\f';
    else if(yytext[2]=='r')ch='\r';
    else if(yytext[2]=='b')ch='\b';
    else if(yytext[2]=='v')ch='\v';
    else if(yytext[2]=='0')ch='\0';
    else if(yytext[2]=='\\')ch='\\';
    else if(yytext[2]=='\'')ch='\'';
    fprintf(logFile,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CONST_CHAR, %c>\n\n",lineCount,yytext,ch);
    fprintf(tokenFile,"<CONST_CHAR, %c> ",ch);
}

("+"|"-") {
    fprintf(logFile,"Line no %d: Token <ADDOP> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<ADDOP, %s> ",yytext);
}

("*"|"/"|"%") {
    fprintf(logFile,"Line no %d: Token <MULOP> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<MULOP, %s> ",yytext);
}

("++"|"--") {
    fprintf(logFile,"Line no %d: Token <INCOP> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<INCOP, %s> ",yytext);
}

("<"|"<="|">"|">="|"=="|"!=") {
    fprintf(logFile,"Line no %d: Token <RELOP> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<RELOP, %s> ",yytext);
}

("=") {
    fprintf(logFile,"Line no %d: Token <ASSIGNOP> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<ASSIGNOP, %s> ",yytext);
}

("&&"|"||") {
    fprintf(logFile,"Line no %d: Token <LOGICOP> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<LOGICOP, %s> ",yytext);
}

("!") {
    fprintf(logFile,"Line no %d: Token <NOT> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<NOT, %s> ",yytext);
}

("(") {
    fprintf(logFile,"Line no %d: Token <LPAREN> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<LPAREN, %s> ",yytext);
}

(")") {
    fprintf(logFile,"Line no %d: Token <RPAREN> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<RPAREN, %s> ",yytext);
}

("{") {
    fprintf(logFile,"Line no %d: Token <LCURL> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<LCURL, %s> ",yytext);
}

("}") {
    fprintf(logFile,"Line no %d: Token <RCURL> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<RCURL, %s> ",yytext);
}

("[") {
    fprintf(logFile,"Line no %d: Token <LTHIRD> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<LTHIRD, %s> ",yytext);
}

("]") {
    fprintf(logFile,"Line no %d: Token <RTHIRD> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<RTHIRD, %s> ",yytext);
}

(",") {
    fprintf(logFile,"Line no %d: Token <COMMA> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<COMMA, %s> ",yytext);
}

(";") {
    fprintf(logFile,"Line no %d: Token <SEMICOLON> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<SEMICOLON, %s> ",yytext);
}


[a-zA-Z_][a-zA-Z0-9_]* {
    fprintf(logFile,"Line no %d: Token <ID> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<ID, %s> ",yytext);
}

"//" {
    commentBody="";
	BEGIN COMMENT_SINGLE_LINE; 
}

[\"] {
    stringBody="";
    logStringBody="";
	BEGIN STRING; 
}

<STRING>"\\"(" "|\t)*[\n] {
    logStringBody+=yytext;
}

<STRING>[\"] {
    fprintf(logFile,"Line no %d: Token <STRING> Lexeme \"%s\" found --> <STRING, %s> \n\n",lineCount,logStringBody.c_str(),stringBody.c_str());
    fprintf(tokenFile,"<STRING, %s> ",stringBody.c_str());
    BEGIN INITIAL; 
}

<STRING>[\n] {
    fprintf(logFile,"Error at line no %d: Unterminated String \"%s \n\n",lineCount,stringBody.c_str());
    BEGIN INITIAL; 
}



<STRING>. {
    stringBody+=yytext;
    logStringBody+=yytext;
}

<STRING>\\[ntafrbv0\'\\] {
    //character constant
    char ch;
    if(yytext[1]=='n')ch='\n';
    else if(yytext[1]=='t')ch='\t';
    else if(yytext[1]=='a')ch='\a';
    else if(yytext[1]=='f')ch='\f';
    else if(yytext[1]=='r')ch='\r';
    else if(yytext[1]=='b')ch='\b';
    else if(yytext[1]=='v')ch='\v';
    else if(yytext[1]=='0')ch='\0';
    else if(yytext[1]=='\\')ch='\\';
    else if(yytext[1]=='\'')ch='\'';
    stringBody+=ch;
    logStringBody+=yytext;
}

<COMMENT_SINGLE_LINE>[\n] {
    BEGIN INITIAL; 
}

<COMMENT_SINGLE_LINE>"\\"(" "|\t)*[\n]  {
    commentBody+=yytext;
}

<COMMENT_SINGLE_LINE>. {
    commentBody+=yytext;
}

(" "|\t)* {}

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