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

int lineCount=1,tmpLineCount,errorCount=0;
FILE *logFile,*tokenFile;
string stringBody;
string logStringBody;
string commentBody;
SymbolTable *symbolTable;


string charPointerToString( char* buf) {
    int max=strlen(buf);
    size_t len = 0;
    while( (len < max) && (buf[ len ] != '\0') ) {
        len++;
    }
    return string( buf, len );
}

%}

Integer [0-9]+
Float [0-9]*([.][0-9]+)?([eE][-+]?[0-9]+)?
SingleQuot \'
  
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

[a-zA-Z_][a-zA-Z0-9_]* {
    fprintf(logFile,"Line no %d: Token <ID> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<ID, %s> ",yytext);
    bool isInserted=symbolTable->insertSymbol(charPointerToString(yytext),"ID");
    if(isInserted)fprintf(logFile,"%s\n\n",symbolTable->printAllScopes().c_str());
    else fprintf(logFile,"%s already exists in the current scope table\n\n",yytext);
}

[0-9]+[a-zA-Z_][a-zA-Z0-9_]* {
    //Invalid prefix before an id
    errorCount++;
    fprintf(logFile,"Error at line no %d: Invalid prefix before ID : %s \n\n",lineCount,yytext);
}

{Integer} {
    //integer constant
    fprintf(logFile,"Line no %d: Token <CONST_INT> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<CONST_INT, %s> ",yytext);
    bool isInserted=symbolTable->insertSymbol(charPointerToString(yytext),"CONST_INT");
    if(isInserted)fprintf(logFile,"%s\n\n",symbolTable->printAllScopes().c_str());
    else fprintf(logFile,"%s already exists in the current scope table\n\n",yytext);
}

{Float} {
    //floating constant
    fprintf(logFile,"Line no %d: Token <CONST_FLOAT> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<CONST_FLOAT, %s> ",yytext);
    bool isInserted=symbolTable->insertSymbol(charPointerToString(yytext),"CONST_FLOAT");
    if(isInserted)fprintf(logFile,"%s\n\n",symbolTable->printAllScopes().c_str());
    else fprintf(logFile,"%s already exists in the current scope table\n\n",yytext);
}

[0-9]*([.][0-9]*)([.][0-9]*)+ {
    //Too many decimal point error
    errorCount++;
    fprintf(logFile,"Error at line no %d: Too many decimal points : %s \n\n",lineCount,yytext);
}

[0-9]*([.][0-9]+)?([eE][-+]?([0-9]*[.])+[0-9]+)|[0-9]*([.][0-9]+)?([eE][-+]?[0-9]+)?([.][0-9]*)+ {
    //Illed formed number
    errorCount++;
    fprintf(logFile,"Error at line no %d: Ill formed number : %s \n\n",lineCount,yytext);
}

({Integer}|{Float})[a-zA-Z]+ {
    //Invalid suffix after a numeric value
    errorCount++;
    fprintf(logFile,"Error at line no %d: Invalid suffix after number : %s \n\n",lineCount,yytext);
}

\'\' {
    //Emply character constant error
    errorCount++;
    fprintf(logFile,"Error at line no %d: Empty character \n\n",lineCount);
}

\'\\\'|\'.|\'\\[ntafrbv0\'\\] {
    //Unfinished character
    errorCount++;
    fprintf(logFile,"Error at line no %d: Unfinished character : %s \n\n",lineCount,yytext);
}


\'.\' {
    //character constant
    fprintf(logFile,"Line no %d: Token <CONST_CHAR> Lexeme %s found  --> <CONST_CHAR, %c> \n\n",lineCount,yytext,yytext[1]);
    fprintf(tokenFile,"<CONST_CHAR, %c> ",yytext[1]);
    bool isInserted=symbolTable->insertSymbol(string(1,yytext[1]),"CONST_CHAR");
    if(isInserted)fprintf(logFile,"%s\n\n",symbolTable->printAllScopes().c_str());
    else fprintf(logFile,"%c already exists in the current scope table\n\n",yytext[1]);
}

{SingleQuot} {
    //Empty character
    errorCount++;
    fprintf(logFile,"Error at line no %d: Empty character constant \n\n",lineCount);
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
    bool isInserted=symbolTable->insertSymbol(string(1,ch),"CONST_CHAR");
    if(isInserted)fprintf(logFile,"%s\n\n",symbolTable->printAllScopes().c_str());
    else fprintf(logFile,"%c already exists in the current scope table\n\n",ch);
}

\'.(.)+\' {
    //Invalid character
    errorCount++;
    fprintf(logFile,"Error at line no %d: Invalid character : %s \n\n",lineCount,yytext);
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
    symbolTable->enterScope();
}

("}") {
    fprintf(logFile,"Line no %d: Token <RCURL> Lexeme %s found\n\n",lineCount,yytext);
    fprintf(tokenFile,"<RCURL, %s> ",yytext);
    symbolTable->exitScope();
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

"//" {
    commentBody="";
    tmpLineCount=lineCount;
	BEGIN COMMENT_SINGLE_LINE; 
}

"/*" {
    commentBody="";
    tmpLineCount=lineCount;
	BEGIN COMMENT_MULTI_LINE; 
}

[\"] {
    stringBody="";
    logStringBody="";
    tmpLineCount=lineCount;
	BEGIN STRING; 
}

<STRING>"\\"(" "|\t)*[\n] {
    logStringBody+=yytext;
    lineCount++;
}

<STRING>[\"] {
    fprintf(logFile,"Line no %d: Token <STRING> Lexeme \"%s\" found --> <STRING, %s> \n\n",tmpLineCount,logStringBody.c_str(),stringBody.c_str());
    fprintf(tokenFile,"<STRING, %s> ",stringBody.c_str());
    BEGIN INITIAL; 
}

<STRING>[\n] {
    errorCount++;
    fprintf(logFile,"Error at line no %d: Unterminated String \"%s \n\n",lineCount,stringBody.c_str());
    lineCount++;
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
    lineCount++;
    BEGIN INITIAL; 
}

<COMMENT_SINGLE_LINE>"\\"(" "|\t)*[\n]  {
    lineCount++;
    commentBody+=yytext;
}

<COMMENT_SINGLE_LINE>. {
    commentBody+=yytext;
}

<COMMENT_MULTI_LINE><<EOF>> {
    errorCount++;
    fprintf(logFile,"Error at line no %d: Unterminated Comment \"%s \n\n",tmpLineCount,commentBody.c_str()); 
    return 0;
}

<COMMENT_MULTI_LINE>"*/"  {
    BEGIN INITIAL; 
}

<COMMENT_MULTI_LINE>. {
    commentBody+=yytext;
}

<COMMENT_MULTI_LINE>\n {lineCount++;}

(" "|\t)* {}

[`#~@$^&] {
    //Unrecognized character
    errorCount++;
    fprintf(logFile,"Error at line no %d: Unrecognized character : %s \n\n",lineCount,yytext);
}

<<EOF>> { 
    return 0;
}

\n {lineCount++;}
%%
  

int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    logFile=fopen(argv[2], "w");
    tokenFile=fopen(argv[3], "w");

    symbolTable=new SymbolTable(11);

    yylex();
    fprintf(logFile,"Total lines: %d\nTotal errors: %d",lineCount,errorCount);
    fclose(yyin);
    fclose(logFile);
    fclose(tokenFile);

    delete symbolTable;
    yy_delete_buffer( YY_CURRENT_BUFFER );

    return 0;
}