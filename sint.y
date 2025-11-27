%{
// стандартные библиотеки для работы с файлами, памятью и строками
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin;
extern FILE *yyout;

// Объявления функций парсера и обработчика ошибок
int yylex(void);        // Лексический анализатор (обычно генерируется flex)
void yyerror(const char *s); // Функция обработки синтаксических ошибок
%}

// Определяем объединение (union) для хранения значений токенов
%union 
{
char var[256];      // Для хранения идентификаторов переменных и функций
char strings[8192]; // Для хранения строковых выражений и блоков кода
}

// Определяем токены (лексемы), которые будут возвращаться лексером
%token <var> LET PLUS MINUS STAR SLASH ASSIGN SEM COMMA LPAREN RPAREN LBRACE RBRACE
%token <var> INT DOUBLE FMOD POW PLUS_ASSIGN MUL_ASSIGN SIN COS TAN ASIN ACOS ATAN
%token <var> OR_ASSIGN AND_ASSIGN XOR_ASSIGN MOD LSHIFT RSHIFT BIT_OR BIT_AND BIT_XOR
%token <var> EXP LOG SQRT PRINTF RETURN STRING FABS INTLASH

// Определяем типы нетерминалов (правил грамматики)
%type <strings> PL MP declarations declaration var_list statement expression term factor bit_expr math_function function_call cast_expression printf_call return_statement
%type <strings> functions function_def func_params assignment_expr statements return_funct
%start MP

%%
// Правила грамматики

// Основное правило - точка входа в грамматику
MP: functions { 
    fprintf(yyout, "%s", $1); 
    fprintf(yyout, "\n# Вызов main функции\nif __name__ == \"__main__\":\n    main()\n");
    return 0; 
}
;

// Правило для разбора последовательности функций
functions: PL { strcpy($$, $1); }  // Если одна функция
    | functions PL { 
        // Если несколько функций - объединяем их
        char temp[16384];
        strcpy(temp, $1);   // Берем уже разобранные функции
        strcat(temp, $2);   // Добавляем новую функцию
        strcpy($$, temp);   // Сохраняем результат
    }
;

// Правило для разбора функции: int main() {...}
PL: INT LET LPAREN RPAREN LBRACE declarations RBRACE {
    // Разбираем функцию без параметров: int main() { ... }
    char func_name[256];
    strcpy(func_name, $2); // $2 - имя функции (main)
    if (strcmp(func_name, "complex") == 0) { // Обработка имени "complex"
        strcpy(func_name, "complex_val");    // Заменяем на "complex_val"
    }
    
    strcpy($$, "def ");      // Начинаем с Python-функции
    strcat($$, func_name);   // Добавляем имя функции
    strcat($$, "():\n");     // Завершаем объявление
    strcat($$, $6);          // Добавляем тело функции (декларации и операторы)
}
| function_def { strcpy($$, $1); } // Или разбираем другое определение функции
;

// Правило для разбора определения функции с параметрами
function_def: DOUBLE LET LPAREN func_params RPAREN LBRACE statements return_funct RBRACE {
    // Разбираем функцию типа: double complexMath(double x, double y) { ... }
    char func_name[256];
    strcpy(func_name, $2); // $2 - имя функции (complexMath)
    if (strcmp(func_name, "complex") == 0) {
        strcpy(func_name, "complex_val");
    }
    
    strcpy($$, "def ");
    strcat($$, func_name);  // Добавляем имя функции
    strcat($$, "(");
    strcat($$, $4);         // $4 - параметры функции (x, y)
    strcat($$, "):\n");
    strcat($$, $7);         // $7 - тело функции (statements)
    strcat($$, $8);         // $8 - return-выражение
}
| INT LET LPAREN func_params RPAREN LBRACE statements return_funct RBRACE {
    // Аналогично для функций типа: int bitOperations(int num) { ... }
    char func_name[256];
    strcpy(func_name, $2);
    if (strcmp(func_name, "complex") == 0) {
        strcpy(func_name, "complex_val");
    }
    
    strcpy($$, "def ");
    strcat($$, func_name);
    strcat($$, "(");
    strcat($$, $4);         // Параметры функции
    strcat($$, "):\n");
    strcat($$, $7);         // Тело функции
    strcat($$, $8);         // Return-выражение
}
;

// Правило для разбора параметров функции
func_params: DOUBLE LET { 
    // Разбираем одиночный параметр: double x
    char var_name[256];
    strcpy(var_name, $2); // $2 - имя параметра (x)
    if (strcmp(var_name, "complex") == 0) {
        strcpy(var_name, "complex_val");
    }
    strcpy($$, var_name); 
}
    | INT LET { 
    // Разбираем одиночный параметр: int num
    char var_name[256];
    strcpy(var_name, $2); // $2 - имя параметра (num)
    if (strcmp(var_name, "complex") == 0) {
        strcpy(var_name, "complex_val");
    }
    strcpy($$, var_name); 
}
    | func_params COMMA DOUBLE LET { 
    // Разбираем несколько параметров: x, double y
    char var_name[256];
    strcpy(var_name, $4); // $4 - имя нового параметра (y)
    if (strcmp(var_name, "complex") == 0) {
        strcpy(var_name, "complex_val");
    }
    
    strcpy($$, $1);        // $1 - уже разобранные параметры (x)
    strcat($$, ", ");      // Добавляем запятую
    strcat($$, var_name);  // Добавляем новое имя параметра
}
    | func_params COMMA INT LET { 
    // Разбираем: ..., int years
    char var_name[256];
    strcpy(var_name, $4); // $4 - имя параметра (years)
    if (strcmp(var_name, "complex") == 0) {
        strcpy(var_name, "complex_val");
    }
    
    strcpy($$, $1);
    strcat($$, ", ");
    strcat($$, var_name);
}
;

// Правило для разбора последовательности операторов
statements: { strcpy($$, ""); } // Пустая последовательность
    | statements statement { 
        // Добавляем новый оператор к уже разобранным
        char temp[8192];
        strcpy(temp, $1);  // $1 - уже разобранные операторы
        strcat(temp, $2);  // $2 - новый оператор
        strcpy($$, temp);
    }
;

// Правило для разбора деклараций (объявлений переменных)
declarations: declaration { strcpy($$, $1); } // Одна декларация
    | statement { strcpy($$, $1); }           // Оператор может быть в начале функции
    | declarations declaration { 
        // Добавляем новую декларацию к уже разобранным
        char temp[16384];
        strcpy(temp, $1);  // $1 - уже разобранные декларации
        strcat(temp, $2);  // $2 - новая декларация
        strcpy($$, temp);
    }
    | declarations statement { 
        // Добавляем оператор к декларациям
        char temp[16384];
        strcpy(temp, $1);  // $1 - декларации
        strcat(temp, $2);  // $2 - оператор
        strcpy($$, temp);
    }
    | /* пусто */ { strcpy($$, ""); } // Пустая декларация
;

// Правило для разбора объявления переменных
declaration: INT var_list SEM {
        // Разбираем: int finalInt, a, b, c, int1, int2, int3, ...;
        strcpy($$, $2);    // $2 - список переменных
    }
    | DOUBLE var_list SEM {
        // Разбираем: double finalResult, arithmetic1, arithmetic2, ...;
        char temp[4096];
        strcpy(temp, $2);  // $2 - список переменных
        char *pos = strstr(temp, "= 0\n"); // Ищем присваивания = 0
        if (pos) {
            strcpy(pos, "= 0.0\n"); // Меняем на = 0.0 для double
        }
        strcpy($$, temp);
    }
;

// Правило для разбора списка переменных
var_list: LET { 
    // Разбираем одиночную переменную: finalResult
    char var_name[256];
    strcpy(var_name, $1); // $1 - имя переменной
    if (strcmp(var_name, "complex") == 0) {
        strcpy(var_name, "complex_val");
    }
    
    char temp[512];
    strcpy(temp, "    ");      // Добавляем отступ
    strcat(temp, var_name);    // Добавляем имя переменной
    strcat(temp, " = 0\n");    // Добавляем инициализацию
    strcpy($$, temp);
}
    | var_list COMMA LET {
    // Разбираем: ..., arithmetic2, arithmetic3
    char var_name[256];
    strcpy(var_name, $3); // $3 - новое имя переменной
    if (strcmp(var_name, "complex") == 0) {
        strcpy(var_name, "complex_val");
    }
    
    char temp[2048];
    strcpy(temp, $1);       // $1 - уже разобранные переменные
    strcat(temp, "    ");   // Добавляем отступ
    strcat(temp, var_name); // Добавляем новое имя
    strcat(temp, " = 0\n"); // Добавляем инициализацию
    strcpy($$, temp);
}
;

// Правило для разбора операторов
statement: LET ASSIGN expression SEM {
    // Разбираем присваивание: finalResult = 0.0;
    char var_name[256];
    strcpy(var_name, $1); // $1 - имя переменной (finalResult)
    if (strcmp(var_name, "complex") == 0) {
        strcpy(var_name, "complex_val");
    }
    
    char temp[1024];
    strcpy(temp, "    ");     // Добавляем отступ
    strcat(temp, var_name);   // Добавляем имя переменной
    strcat(temp, " = ");      // Добавляем оператор присваивания
    strcat(temp, $3);         // $3 - выражение справа
    strcat(temp, "\n");       // Завершаем строку
    strcpy($$, temp);
}
    | printf_call { strcpy($$, $1); }      // Разбираем вызов printf
    | return_statement { strcpy($$, $1); } // Разбираем return
    | assignment_expr SEM { 
        // Разбираем выражение с присваиванием: finalInt = 0;
        char temp[1024];
        strcpy(temp, "    "); // Добавляем отступ
        strcat(temp, $1);     // $1 - выражение присваивания
        strcat(temp, "\n");   // Завершаем строку
        strcpy($$, temp);
    }
;

// Правило для разбора выражений присваивания
assignment_expr: DOUBLE LET ASSIGN expression {
    // Разбираем: double principal = ...
    char var_name[256];
    strcpy(var_name, $2); // $2 - имя переменной (principal)
    if (strcmp(var_name, "complex") == 0) {
        strcpy(var_name, "complex_val");
    }
    
    char temp[512];
    strcpy(temp, var_name); // Добавляем имя переменной
    strcat(temp, " = ");    // Добавляем оператор присваивания
    strcat(temp, $4);       // $4 - выражение справа
    strcpy($$, temp);
}
;

// Правило для разбора выражений (арифметических)
expression: bit_expr { strcpy($$, $1); } // Базовый случай
    | expression PLUS bit_expr {
        // Разбираем сложение: arithmetic1 + arithmetic2
        char temp[1024];
        strcpy(temp, "(");    // Добавляем скобки
        strcat(temp, $1);     // $1 - левое выражение
        strcat(temp, " + ");  // Оператор сложения
        strcat(temp, $3);     // $3 - правое выражение
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | expression MINUS bit_expr {
        // Разбираем вычитание: x - y
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);
        strcat(temp, " - ");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | cast_expression { strcpy($$, $1); } // Выражение с приведением типа
;

// Правило для разбора битовых выражений
bit_expr: term { strcpy($$, $1); } // Базовый случай
    | bit_expr BIT_OR term {
        // Разбираем побитовое ИЛИ: a | b
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);      // Левая часть
        strcat(temp, " | ");   // Оператор ИЛИ
        strcat(temp, $3);      // Правая часть
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | bit_expr BIT_XOR term {
        // Разбираем XOR: bit3 ^ bit6
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);
        strcat(temp, " ^ ");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | bit_expr BIT_AND term {
        // Разбираем побитовое И: a & b
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);
        strcat(temp, " & ");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | bit_expr LSHIFT term {
        // Разбираем сдвиг влево: bit1 << bit2
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);
        strcat(temp, " << ");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | bit_expr RSHIFT term {
        // Разбираем сдвиг вправо: bit4 >> bit5
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);
        strcat(temp, " >> ");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
;

// Правило для разбора термов (умножение/деление)
term: factor { strcpy($$, $1); } // Базовый случай
    | term STAR factor {
        // Разбираем умножение: arithmetic1 * arithmetic2
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);      // Левый операнд
        strcat(temp, " * ");   // Оператор умножения
        strcat(temp, $3);      // Правый операнд
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | term SLASH factor {
        // Разбираем деление: arithmetic4 / arithmetic3
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);
        strcat(temp, " / ");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | term INTLASH factor {
        // Разбираем целочисленное деление: int2 // int3
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);
        strcat(temp, " // ");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | term MOD factor {
        // Разбираем остаток от деления: a % b
        char temp[1024];
        strcpy(temp, "(");
        strcat(temp, $1);
        strcat(temp, " % ");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
;

// Правило для разбора факторов (базовых элементов выражений)
factor: LET { 
    // Разбираем имя переменной: finalResult, arithmetic1, x, y и т.д.
    char var_name[256];
    strcpy(var_name, $1); // $1 - имя переменной
    if (strcmp(var_name, "complex") == 0) {
        strcpy(var_name, "complex_val");
    }
    strcpy($$, var_name); 
}
    | LPAREN expression RPAREN { strcpy($$, $2); } // Разбираем выражения в скобках
    | math_function { strcpy($$, $1); }           // Математические функции
    | function_call { strcpy($$, $1); }           // Вызовы функций
    | cast_expression { strcpy($$, $1); }         // Приведение типов
;

// Правило для разбора приведения типов
cast_expression: LPAREN INT RPAREN factor {
        // Разбираем: (int)finalResult
        char temp[1024];
        strcpy(temp, "int(");   // Начало вызова функции приведения
        strcat(temp, $4);       // $4 - выражение для приведения
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | LPAREN DOUBLE RPAREN factor {
        // Разбираем: (double)someValue (хотя в коде этого нет, но грамматика поддерживает)
        char temp[1024];
        strcpy(temp, "float("); // В Python double -> float
        strcat(temp, $4);
        strcat(temp, ")");
        strcpy($$, temp);
    }
;

// Правило для разбора вызовов printf
printf_call: PRINTF LPAREN STRING RPAREN SEM {
        // Разбираем: printf("Результат: %.3f\n", finalResult);
        char temp[1024];
        strcpy(temp, "    print("); // Преобразуем в Python print
        strcat(temp, $3);           // $3 - строка формата
        strcat(temp, ")\n");
        strcpy($$, temp);
    }
    | PRINTF LPAREN STRING COMMA expression RPAREN SEM {
        // Разбираем: printf("Результат: %d\n", finalInt);
        char temp[1024];
        strcpy(temp, "    print(");
        strcat(temp, $3);           // Строка формата
        strcat(temp, " % (");       // Форматирование в Python
        strcat(temp, $5);           // Выражение для подстановки
        strcat(temp, "))\n");
        strcpy($$, temp);
    }
;

// Правило для разбора return-операторов
return_statement: RETURN expression SEM {
        // Разбираем: return sin(x) * cos(y) + ...;
        char temp[512];
        strcpy(temp, "    return "); // Добавляем отступ и return
        strcat(temp, $2);            // $2 - возвращаемое выражение
        strcat(temp, "\n");          // Завершаем строку
        strcpy($$, temp);
    }
    | RETURN SEM {
        // Разбираем: return;
        strcpy($$, "    return\n");
    }
;

// Правило для разбора return в конце функции
return_funct: RETURN expression SEM { 
        // Разбираем return в конце функции
        char temp[512];
        strcpy(temp, "    return ");
        strcat(temp, $2);
        strcat(temp, "\n");
        strcpy($$, temp);
    }
;

// Правило для разбора математических функций
math_function: FMOD LPAREN expression COMMA expression RPAREN {
        // Разбираем: fmod(28.0, 3.0)
        char temp[1024];
        strcpy(temp, "math.fmod("); // Преобразуем в Python math.fmod
        strcat(temp, $3);           // Первый аргумент
        strcat(temp, ", ");
        strcat(temp, $5);           // Второй аргумент
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | POW LPAREN expression COMMA expression RPAREN {
        // Разбираем: pow(x, y)
        char temp[1024];
        strcpy(temp, "math.pow(");
        strcat(temp, $3);
        strcat(temp, ", ");
        strcat(temp, $5);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | SIN LPAREN expression RPAREN {
        // Разбираем: sin(0.5)
        char temp[1024];
        strcpy(temp, "math.sin(");
        strcat(temp, $3);           // Аргумент функции
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | COS LPAREN expression RPAREN {
        // Разбираем: cos(0.3)
        char temp[1024];
        strcpy(temp, "math.cos(");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | TAN LPAREN expression RPAREN {
        // Разбираем: tan(0.1)
        char temp[1024];
        strcpy(temp, "math.tan(");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | ASIN LPAREN expression RPAREN {
        // Разбираем: asin(trig6)
        char temp[1024];
        strcpy(temp, "math.asin(");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | ACOS LPAREN expression RPAREN {
        // Разбираем: acos(trig7)
        char temp[1024];
        strcpy(temp, "math.acos(");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | ATAN LPAREN expression RPAREN {
        // Разбираем: atan(...)
        char temp[1024];
        strcpy(temp, "math.atan(");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | EXP LPAREN expression RPAREN {
        // Разбираем: exp(1.0)
        char temp[1024];
        strcpy(temp, "math.exp(");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | LOG LPAREN expression RPAREN {
        // Разбираем: log(10.0)
        char temp[1024];
        strcpy(temp, "math.log(");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | SQRT LPAREN expression RPAREN {
        // Разбираем: sqrt(144.0)
        char temp[1024];
        strcpy(temp, "math.sqrt(");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
    | FABS LPAREN expression RPAREN {
        // Разбираем: fabs(x - y)
        char temp[1024];
        strcpy(temp, "math.fabs(");
        strcat(temp, $3);
        strcat(temp, ")");
        strcpy($$, temp);
    }
;

// Правило для разбора вызовов пользовательских функций
function_call: LET LPAREN RPAREN {
    // Разбираем вызов без аргументов: bitOperations()
    char func_name[256];
    strcpy(func_name, $1); // $1 - имя функции
    if (strcmp(func_name, "complex") == 0) {
        strcpy(func_name, "complex_val");
    }
    
    char temp[1024];
    strcpy(temp, func_name);
    strcat(temp, "()");    // Добавляем скобки
    strcpy($$, temp);
}
    | LET LPAREN expression RPAREN {
    // Разбираем вызов с одним аргументом: bitOperations(42)
    char func_name[256];
    strcpy(func_name, $1);
    if (strcmp(func_name, "complex") == 0) {
        strcpy(func_name, "complex_val");
    }
    
    char temp[1024];
    strcpy(temp, func_name);
    strcat(temp, "(");
    strcat(temp, $3);      // $3 - аргумент
    strcat(temp, ")");
    strcpy($$, temp);
}
    | LET LPAREN expression COMMA expression RPAREN {
    // Разбираем вызов с двумя аргументами: financialCalculations(1000.0, 5.0, 10)
    char func_name[256];
    strcpy(func_name, $1);
    if (strcmp(func_name, "complex") == 0) {
        strcpy(func_name, "complex_val");
    }
    
    char temp[1024];
    strcpy(temp, func_name);
    strcat(temp, "(");
    strcat(temp, $3);      // Первый аргумент
    strcat(temp, ", ");
    strcat(temp, $5);      // Второй аргумент
    strcat(temp, ")");
    strcpy($$, temp);
}
    | LET LPAREN expression COMMA expression COMMA expression RPAREN {
    // Разбираем вызов с тремя аргументами: pow(1 + rate / 100.0, years)
    char func_name[256];
    strcpy(func_name, $1);
    if (strcmp(func_name, "complex") == 0) {
        strcpy(func_name, "complex_val");
    }
    
    char temp[1024];
    strcpy(temp, func_name);
    strcat(temp, "(");
    strcat(temp, $3);      // Первый аргумент
    strcat(temp, ", ");
    strcat(temp, $5);      // Второй аргумент
    strcat(temp, ", ");
    strcat(temp, $7);      // Третий аргумент
    strcat(temp, ")");
    strcpy($$, temp);
}
;

%%

// Основная функция программы
int main(void) {
    // Открываем входной файл для чтения
    yyin = fopen("start.c", "r");
    // Открываем выходной файл для записи
    yyout = fopen("result.txt", "w");
    
    // Проверяем, удалось ли открыть входной файл
    if (!yyin) {
        printf("Error: Cannot open start.c\n");
        return 1;
    }
    // Проверяем, удалось ли открыть выходной файл
    if (!yyout) {
        printf("Error: Cannot open result.txt\n");
        fclose(yyin);
        return 1;
    }
    
    // Записываем импорт модуля math в начало Python-файла
    fprintf(yyout, "import math\n\n");
    
    // Запускаем парсер для разбора входного файла
    yyparse();

    // Закрываем файлы
    fclose(yyin);
    fclose(yyout);
    return 0;
}

// Функция обработки синтаксических ошибок
void yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
} 