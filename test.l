%option noyywrap

/*** Definition Section has one variable
which can be accessed inside yylex()
and main() ***/
%x STRING_STATE
%{
#include<iostream>
using namespace std;
#include <string>
#include <stdlib.h>
FILE *fpin,*fpout,*fplog;
int line_count=1;
string s,original;
%}

AlphaNumeric [a-zA-Z0-9]
digit [0-9]
letter [A-Za-z]
delim [\t\n]
inca [+][+]
deca [-][-]

%%
[\n] {line_count++;}
(if) {fprintf(fpout,"<IF>");fprintf(fplog,"Line no %d: Token <IF> Lexeme if found\n\n",line_count);}
(for) {fprintf(fpout,"<FOR>");fprintf(fplog,"Line no %d: Token <FOR> Lexeme for found\n\n",line_count);}
(do) {fprintf(fpout,"<DO>");fprintf(fplog,"Line no %d: Token <DO> Lexeme do found\n",line_count);}
(int) {fprintf(fpout,"<INT>");fprintf(fplog,"Line no %d: Token <INT> Lexeme int found\n",line_count);}
(float) {fprintf(fpout,"<FLOAT>");fprintf(fplog,"Line no %d: Token <FLOAT> Lexeme float found\n",line_count);}
(void) {fprintf(fpout,"<VOID>");fprintf(fplog,"Line no %d: Token <VOID> Lexeme void found\n",line_count);}
(switch) {fprintf(fpout,"<SWITCH>");fprintf(fplog,"Line no %d: Token <SWITCH> Lexeme switch found\n",line_count);}
(default) {fprintf(fpout,"<DEFAULT>");fprintf(fplog,"Line no %d: Token <DEFAULT> Lexeme default found\n\n",line_count);}
(else) {fprintf(fpout,"<ELSE>");fprintf(fplog,"Line no %d: Token <ELSE> Lexeme else found\n\n",line_count);}
(while) {fprintf(fpout,"<WHILE>");fprintf(fplog,"Line no %d: Token <WHILE> Lexeme while found\n\n",line_count);}
(break) {fprintf(fpout,"<BREAK>");fprintf(fplog,"Line no %d: Token <BREAK> Lexeme break found\n\n",line_count);}
(char) {fprintf(fpout,"<CHAR>");fprintf(fplog,"Line no %d: Token <CHAR> Lexeme char found\n\n",line_count);}
(double) {fprintf(fpout,"<DOUBLE>");fprintf(fplog,"Line no %d: Token <DOUBLE> Lexeme double found\n\n",line_count);}
(return) {fprintf(fpout,"<RETURN>");fprintf(fplog,"Line no %d: Token <RETURN> Lexeme return found\n\n",line_count);}
(case) {fprintf(fpout,"<CASE>");fprintf(fplog,"Line no %d: Token <CASE> Lexeme case found\n\n",line_count);}
(continue) {fprintf(fpout,"<CONTINUE>");fprintf(fplog,"Line no %d: Token <CONTINUE> Lexeme continue found\n\n",line_count);}
(;) {fprintf(fpout,"<SEMICOLON>");fprintf(fplog,"Line no %d: Token <SEMICOLON> Lexeme %s found\n\n",line_count,yytext);}
{digit}* {fprintf(fpout,"<CONST_INT,%s>",yytext);}

{digit}*([.]{digit}+)?([Ee][+-]?{digit}+)? {fprintf(fpout,"<CONST_FLOAT,%s>",yytext);}
['].['] {fprintf(fpout,"<CONST_CHAR,%c>",yytext[1]);fprintf(fplog,"Line no %d: Token <CONST_CHAR> Lexeme %c found --> <CHAR_CONST, %c\n\n>",line_count,yytext[1],yytext[1]);}

[']\\[nt\\afrbv0\'][']  {

	char ch;
	if(yytext[2]=='n'){
		ch='\n';
	}else if(yytext[2]=='t'){
	ch='\t';
	}else if(yytext[2]=='a'){
		ch='\a';
	}else if(yytext[2]=='f'){
		ch='\f';
	}else if(yytext[2]=='r'){
		ch='\r';
	}else if(yytext[2]=='b'){
		ch='\b';
	}else if(yytext[2]=='v'){
		ch='\v';
	}else if(yytext[2]=='0'){
		ch='\0';
	}else if(yytext[2]=='\\'){
		ch='\\';
	}else if(yytext[2]=='\''){
		ch='\'';
	}

	fprintf(fpout,"<CONST_CHAR,%c>",ch);
	fprintf(fplog,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST, %c\n\n>",line_count,yytext,ch);
	
}

("+"|"-") {fprintf(fpout,"<ADDOP>");fprintf(fplog,"Line no %d: Token <ADDOP> Lexeme %s found\n\n",line_count,yytext);}
("*"|"/"|"%") {fprintf(fpout,"<MULOP>");fprintf(fplog,"Line no %d: Token <MULOP> Lexeme %s found\n\n",line_count,yytext);}

("<"|"<="|">"|">="|"=="|"!=") {fprintf(fpout,"<RELOP>");fprintf(fplog,"Line no %d: Token <RELOP> Lexeme %s found\n\n",line_count,yytext);}
"=" {fprintf(fpout,"<ASSIGNOP>");fprintf(fplog,"Line no %d: Token <ASSIGNOP> Lexeme %s found\n\n",line_count,yytext);}
("&&","||") {fprintf(fpout,"<LOGIOP>");fprintf(fplog,"Line no %d: Token <LOGIOP> Lexeme %s found\n\n",line_count,yytext);}
"!" {fprintf(fpout,"<NOT>");fprintf(fplog,"Line no %d: Token <NOT> Lexeme %s found\n\n",line_count,yytext);}
"(" {fprintf(fpout,"<LPAREN>");fprintf(fplog,"Line no %d: Token <LPAREN> Lexeme %s found\n\n",line_count,yytext);}
")" {fprintf(fpout,"<RPAREN>");fprintf(fplog,"Line no %d: Token <RPAREN> Lexeme %s found\n\n",line_count,yytext);}
"[" {fprintf(fpout,"<LTHIRD>");fprintf(fplog,"Line no %d: Token <LTHIRD> Lexeme %s found\n\n",line_count,yytext);}
"]" {fprintf(fpout,"<RTHIRD>");fprintf(fplog,"Line no %d: Token <RTHIRD> Lexeme %s found\n\n",line_count,yytext);}
","  {fprintf(fpout,"<COMMA>");fprintf(fplog,"Line no %d: Token <COMMA> Lexeme %s found\n\n",line_count,yytext);}
"{"  {fprintf(fpout,"<LCURL>");fprintf(fplog,"Line no %d: Token <LCURL> Lexeme %s found\n\n",line_count,yytext);}
"}"  {fprintf(fpout,"<RCURL>");fprintf(fplog,"Line no %d: Token <RCURL> Lexeme %s found\n\n",line_count,yytext);}
("++"|"--")  {fprintf(fpout,"<INCOP>");fprintf(fplog,"Line no %d: Token <INCOP> Lexeme %s found\n\n",line_count,yytext);}

[a-zA-Z_][a-zA-Z0-9_]*  {fprintf(fpout,"<ID,%s>",yytext);fprintf(fplog,"Line no %d: Token <ID> Lexeme %s found\n\n",line_count,yytext);}

[\"] {original=""; s=""; BEGIN STRING_STATE;}

<STRING_STATE>[\\]][\n] {
	original+=yytext;
}

<STRING_STATE>[\"]  {
    fprintf(fplog,"Line no %d: Token <STRING> Lexeme \"%s\" found --> <STRING, %s> \n\n",line_count,original.c_str(),s.c_str());
    fprintf(fpout,"<STRING, %s> ",s.c_str());
    BEGIN INITIAL; 
}

<STRING_STATE>[\r][\n] {
	fprintf(fplog,"Error at line no %d: Unterminated String \"%s \n\n",line_count,s.c_str());
	BEGIN INITIAL;
}

<STRING_STATE>. {
	s+=yytext;
	original+=yytext;
}



<STRING_STATE>[']\\[nt\\afrbv0\']['] {
	char ch;
	if(yytext[2]=='n'){
		ch='\n';
	}else if(yytext[2]=='t'){
	ch='\t';
	}else if(yytext[2]=='a'){
		ch='\a';
	}else if(yytext[2]=='f'){
		ch='\f';
	}else if(yytext[2]=='r'){
		ch='\r';
	}else if(yytext[2]=='b'){
		ch='\b';
	}else if(yytext[2]=='v'){
		ch='\v';
	}else if(yytext[2]=='0'){
		ch='\0';
	}else if(yytext[2]=='\\'){
		ch='\\';
	}else if(yytext[2]=='\''){
		ch='\'';
	}
	s+=ch;
	original+=yytext;
}



%%


int main(){


fpin = fopen("sample_input4.txt","r");
fpout=fopen("output.txt","w");
fplog=fopen("log.txt","w");
yyin=fpin;
yylex();
fclose(yyin);
fclose(fplog);
fclose(fpout);
return 0;
}
