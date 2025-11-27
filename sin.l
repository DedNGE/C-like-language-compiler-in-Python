%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
%}

%%

"#include"    { /* пропускаем директивы include */ }
"#define"     { /* пропускаем директивы define */ }
"#ifdef"      {  }
"#ifndef"     {  }
"#endif"      {  }

"printf"      { return PRINTF; }
"return"      { return RETURN; }
"int"         { return INT; }
"double"      { return DOUBLE; }
"fmod"        { return FMOD; }
"pow"         { return POW; }
"sin"         { return SIN; }
"cos"         { return COS; }
"tan"         { return TAN; }
"asin"        { return ASIN; }
"acos"        { return ACOS; }
"atan"        { return ATAN; }
"exp"         { return EXP; }
"log"         { return LOG; }
"sqrt"        { return SQRT; }
"fabs"        { return FABS; }

\"[^\"]*\"    { strcpy(yylval.var, yytext); return STRING; }

"+"           { strcpy(yylval.var, "+"); return PLUS; }
"-"           { strcpy(yylval.var, "-"); return MINUS; }
"*"           { strcpy(yylval.var, "*"); return STAR; }
"/"           { strcpy(yylval.var, "/"); return SLASH; }
"//"          { strcpy(yylval.var, "//"); return INTLASH; }
"%"           { strcpy(yylval.var, "%"); return MOD; }
"&"           { strcpy(yylval.var, "&"); return BIT_AND; }
"|"           { strcpy(yylval.var, "|"); return BIT_OR; }
"^"           { strcpy(yylval.var, "^"); return BIT_XOR; }
"<<"          { strcpy(yylval.var, "<<"); return LSHIFT; }
">>"          { strcpy(yylval.var, ">>"); return RSHIFT; }
"="           { strcpy(yylval.var, "="); return ASSIGN; }
"+="          { strcpy(yylval.var, "+="); return PLUS_ASSIGN; }
"*="          { strcpy(yylval.var, "*="); return MUL_ASSIGN; }
"|="          { strcpy(yylval.var, "|="); return OR_ASSIGN; }
"^="          { strcpy(yylval.var, "^="); return XOR_ASSIGN; }
"&="          { strcpy(yylval.var, "&="); return AND_ASSIGN; }
";"           { return SEM; }
","           { return COMMA; }
"("           { return LPAREN; }
")"           { return RPAREN; }
"{"           { return LBRACE; }
"}"           { return RBRACE; }

[0-9]+                { strcpy(yylval.var, yytext); return LET; }
[0-9]*\.[0-9]+([eE][-+]?[0-9]+)? { strcpy(yylval.var, yytext); return LET; }
[a-zA-Z_][a-zA-Z0-9_]* { strcpy(yylval.var, yytext); return LET; }

[ \t\n]               ;
.                     { /* пропускаем неизвестные символы вместо ошибки */ }

%%

int yywrap() { return 1; }