/*yylineno记录行号*/
%option yylineno  
/*定义部分*/
%{
    #include "parser.tab.h"
    #include <string.h>
    #include "def.h"
    int yycolumn = 1;
    #define YY_USER_ACTION yylloc.first_line=yylloc.last_line=yylineno; yylloc.first_column=yycolumn; yylloc.last_column=yycolumn+yyleng-1; yycolumn+=yyleng;
    typedef union{
        int type_int;
        float type_float;
        char type_char;
        char type_id[32];
        struct node *ptr;
    }YYLVAL;
    #define YYSTYPE YYLVAL
%}
/*辅助定义*/
id [A-Za-z][A-Za-z0-9]*
int [0-9]+
float ([0-9]*\.[0-9]+)|([0-9]+\.)
char \"(\\.|[^"\\])*\"

/*规则部分：正规表达式+动作， 词法分析器识别出一个单词后，将该单词对应的字符串保存在 yytext中，其长度为yyleng*/
/* 通过yylval.type_int=atoi(yytext);将整常数的值保存在yylval的成员type_in中，这里 yylval 是一个 Flex 和 Bison 共用的内部变量，类型为 YYLVAL，按这样的方式，在 Flex 中通过 yylval 的成员保存单词属性值，在 Bison 中就可以通过yylval 的成员取出属性值，实现了数据的传递*/
%%
{int} {yylval.type_int=atoi(yytext);return INT;}
{float} {yylval.type_float=atof(yytext); return FLOAT;}
{char} {yylval.type_char=yytext; return CHAR}
"int" {strcpy(yylval.type_id,yytext); return TYPE;}
"float" {strcpy(yylval.type_id,yytext); return TYPE;}
"char" {strcpy(yylval.type_id,yytext); return TYPE;}
"return" {return RETURN;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
{id} {strcpy(yylval.type_id,yytext); return ID;}
";" {return SEMI;}
"," {return COMMA;}
">" | "<" | ">=" | "<=" | "==" | "!=" {strcpy(yylval.type_id,yytext); return RELOP;}
"=" {return ASSIGNOP;}
"+" {return PLUS;}
"-" {return MINUS;}
"*" {return STAR;}
"/" {return DIV;}
"&&" {return AND;}
"||" {return OR;}
"!" {return NOT;}
"(" {return LP;}
")" {return RP;}
"{" {return LC;}
"}" {return RC;}
[\n] {yycolumn=1;}
[\r\t] {}
. {printf("Error type A: Mysterious character\"%s\"\n\n at line %d\n",yytext,yylineno);}
 /*注释处理*/
//[.]* {}
"/*"([^\*]|(\*)*[^\*/])*(\*)*"*/" {}

%%
/* 复制到lex.yy.c中*/
void main(){
    yylex();
    return 0;
}