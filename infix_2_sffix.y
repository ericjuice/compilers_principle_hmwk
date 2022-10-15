// %{到%%为定义段
%{ // C语言定义

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef YYSTYPE
#define YYSTYPE char*
#endif

char idStr[50];
char numStr[50];

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s );
%}

// yacc符号定义
%token NUMBER
%token ID
%token T_PLUS T_MINUS T_MULTIPLY T_DIVIDE T_LEFT T_RIGHT T_MOD
%token QUIT
// 优先级递增⬇
%left T_PLUS T_MINUS
%left T_MULTIPLY T_DIVIDE
%left T_MOD
%right UMINUS

%start lines

%%
// 规则段

lines   :   lines expr ';' { printf("%s\n", $2); } // line:空白字符
        |   lines ';'
        |
        |   lines QUIT {printf("exit!\n");exit(0);}
        //|   QUIT ';' {printf("exit!\n");exit(0);}
        ;

expr    :   expr T_PLUS expr { $$ = (char *)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"+ "); } // +号转后缀
        |   expr T_MINUS expr { $$ = (char *)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"- "); } // -号转后缀
        |   expr T_MULTIPLY expr { $$ = (char *)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"* "); } // *号转后缀
        |   expr T_DIVIDE expr { $$ = (char *)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"/ "); } // /号转后缀
        |   expr T_MOD expr { $$ = (char *)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"% "); } // %号转后缀
        |   T_LEFT expr T_RIGHT  { $$ = (char *)malloc(50*sizeof(char)); strcpy($$,$2);} // 括号改变优先级
        |   T_MINUS expr %prec UMINUS { $$ = (char *)malloc(50*sizeof(char)); strcpy($$,"-");strcat($$,$2); }   // 负号
        |   NUMBER { $$ = (char *)malloc(50*sizeof (char)); strcpy($$, $1); strcat($$," ");} // 数字和ID就加空格
        |   ID { $$ = (char *)malloc(50*sizeof (char)); strcpy($$, $1); strcat($$," ");}
        ;

%%

// programs section

int yylex()
{
    // place your token retrieving code here
    int t;
    while (1)
    {
        t = getchar();
        if (t == ' ' || t == '\t' || t == '\n') //是空白
            ;
        else if ((t >= '0' && t <= '9'))    // 是数字
        {
            int ti = 0;
            while ((t >= '0' && t <= '9'))
            {
                numStr[ti] = t;
                t = getchar();
                ti++;
            }
            numStr[ti] = '\0';
            yylval = numStr;    // yylval是自动定义的全局变量
            ungetc(t, stdin);   // 剩余的字符送回输入流
            return NUMBER;
        }
        // 是id
        else if ((t >= 'a' && t <= 'z') || (t >= 'A' && t <= 'Z') || (t == '_'))
        {
            int ti = 0;
            while ((t >= 'a' && t <= 'z') || (t >= 'A' && t <= 'Z') || (t == '_') || (t >= '0' && t <= '9'))
            {
                idStr[ti] = t;
                ti++;
                t = getchar();
            }
            idStr[ti] = '\0';
            yylval = idStr;
            ungetc(t, stdin);
            return ID;
        }
        else {  // 是符号
            switch(t){
                case '+':
                    return T_PLUS;
                    break;
                case '-':
                    return T_MINUS;
                    break;
                case '*':
                    return T_MULTIPLY ;
                    break;
                case '/':
                    return T_DIVIDE;
                    break;
                case '(':
               	    return T_LEFT;
               	    break;
               	case ')':
               	    return T_RIGHT;
               	    break;
               	case ';':
               	    return ';';
               	    break;
               	case '%':
               	    return T_MOD;
               	    break;
               	case '!':
               	    return QUIT;
               	    break;
                default:
                    printf("无法解析符号%c\n",t);
                    return t;
            }
        }
        //     if(t == '+') return ADD;
        // else
        // {
        //     return t;
        // }
    }
}

int main(void)
{
    printf("started,input '!' to quit,input ';' to end up input\n");
    yyin = stdin;
    do
    {
        yyparse();
    } while (!feof(yyin));
    return 0;
}

void yyerror(const char *s)
{
    fprintf(stderr, "Parse error: %s\n", s);
    exit(1);
}
