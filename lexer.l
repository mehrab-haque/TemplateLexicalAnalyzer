%{
int linecount=0;
FILE *logFile,*tokenFile;
%}
  
%%
[if] {
    fprintf(logFile, "if paisi\n");
}
\n {linecount++;}

%%
  
int yywrap(){}
int main(int argc, char *argv[]){

yyin = fopen(argv[1], "r");
logFile=fopen(argv[2], "w");
tokenFile=fopen(argv[3], "w");
yylex();
fprintf(logFile,"lines  %d", linecount);
fclose(yyin);
fclose(logFile);
fclose(tokenFile);
return 0;
}