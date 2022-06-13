%option noyywrap

%x STATE_TEMPLATE

%{
#include<iostream>
#include<cstdio>

#include<string>
#include<cstring>

using namespace std;

FILE *logFile;
string templateBody;
string lastId;
int angleCounter=0;
bool isRightFound=false;

%}

WHITESPACE (" "|\t|\n|\r)*
ID [a-zA-Z_][a-zA-Z0-9_]*
TEMPLATE {ID}{WHITESPACE}<{WHITESPACE}{ID}{WHITESPACE}>
RECURSIVE_TEMPLATE {ID}{WHITESPACE}<{WHITESPACE}{TEMPLATE}{WHITESPACE}>

INCOMPLETE_TEMPLATE {ID}{WHITESPACE}<{WHITESPACE}{ID}{WHITESPACE}
INCOMPLETE_RECURSIVE_TEMPLATE {ID}{WHITESPACE}<{WHITESPACE}{TEMPLATE}{WHITESPACE}>

%%

{ID} {
    templateBody=string(yytext,strlen(yytext));
    lastId=string(yytext,strlen(yytext));
    isRightFound=false;
    BEGIN STATE_TEMPLATE;
}

{WHITESPACE}|[>] {}

<STATE_TEMPLATE>[<] {
    if(!isRightFound){
        templateBody+="<";
        angleCounter++;
    }else{
        fprintf(logFile,"Unfinished template %s detected\n\n",yytext);
        templateBody=string(yytext,strlen(yytext));
        lastId=string(yytext,strlen(yytext));
        angleCounter=0;
        isRightFound=false;
    }
}

<STATE_TEMPLATE>{WHITESPACE} {}

<STATE_TEMPLATE>[>] {
    templateBody+=">";
    angleCounter--;
    if(angleCounter==0){
        fprintf(logFile,"Template %s detected\n\n",templateBody.c_str());
        BEGIN INITIAL;
    }
    isRightFound=true;
}

<STATE_TEMPLATE>{ID} {
    if(!isRightFound){
        templateBody+=string(yytext,strlen(yytext));
        if(lastId.compare(string(yytext,strlen(yytext)))==0){
            fprintf(logFile,"Invalid template %s detected\n\n",templateBody.c_str());
            templateBody="";
            angleCounter=0;
            lastId="";
            BEGIN INITIAL;
        }
        lastId=string(yytext,strlen(yytext));
    }else{
        angleCounter=0;
        fprintf(logFile,"Unfinished template %s detected\n\n",templateBody.c_str());
        templateBody=string(yytext,strlen(yytext));
        lastId=string(yytext,strlen(yytext));
        isRightFound=false;
    }
}

<STATE_TEMPLATE><<EOF>> {
    if(angleCounter!=0)
        fprintf(logFile,"Unfinished template %s detected\n\n",templateBody.c_str());
    return 0;
}

<<EOF>> {
    if(angleCounter!=0)
        fprintf(logFile,"Unfinished template %s detected\n\n",templateBody.c_str());
    return 0;
}

%%
  

int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    logFile=fopen(argv[2], "w");

    yylex();

    fclose(yyin);
    fclose(logFile);

    yy_delete_buffer( YY_CURRENT_BUFFER );

    return 0;
}