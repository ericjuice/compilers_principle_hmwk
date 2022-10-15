%{
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#ifndef YYSTYPE
#define YYSTYPE double
#endif
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char*s);
%}

//%token NUMBER
%token FLOAT
%token INT
%token ADD SUB
%token MUL DIV MOD
%token L_PAR R_PAR

%left  ADD SUB
%left  MUL DIV MOD
%right UMINUS

%%
lines : lines expr ';' {printf("%f\n",$2);}//分号end
      | lines '\n'
      |
      ;
// 
expr  : expr ADD expr {$$=$1+$3;}
      | expr SUB expr {$$=$1-$3;}
      | expr MUL expr {$$=$1*$3;}
      | expr DIV expr {$$=$1/$3;}
      | expr MOD expr {$$=(int)$1%(int)$3;}
      | L_PAR expr R_PAR {$$=$2;}
      | SUB expr %prec UMINUS { $$ = -$2; }
      |FLOAT{$$=$1;}
      |INT{$$=$1;}
      ;

%%

int yylex()
{
    int t;
    while(1)
    {
        t=getchar();
        if(t==' '||t=='\t'||t=='\n')
        {
            //do nothing
        }
        else if(isdigit(t))
        {
            yylval=0;
            while(isdigit(t))
            {
                yylval=yylval*10+t-'0'; 
                t=getchar();
            }
            if(t=='.'){
                double temp=0.1;
                t=getchar();
                while(isdigit(t))
                {
                    yylval=yylval+(t-'0')*temp; 
                    temp/=10;
                    t=getchar();
                }
                ungetc(t,stdin);
                return FLOAT;
            }else{
                ungetc(t,stdin);
                return INT;
            }
            
        }
        else if(t=='+') return ADD;
        else if(t=='-') return SUB;
        else if(t=='*') return MUL;
        else if(t=='/') return DIV;
        else if(t=='(') return L_PAR;
        else if(t==')') return R_PAR;
        else if(t=='%') return MOD;
        else return t;

    }
}
int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }
    while(!feof(yyin));
    return 0;
}
void yyerror(const char* s)
{
    fprintf(stderr,"Parse error:%s\n",s);
    exit(1);
}



