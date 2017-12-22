%module basic_type

%{
    #include <basic_type.hpp>
%}

int int_a;
short short_a;
long long_a;
signed signed_a; // =int
unsigned unsigned_a;
unsigned short us_a;
unsigned long ul_a;
unsigned char uc_a; //也会转为int
signed char sc_a; //也会转为int
//64bit的可能会被截断
float float_a;
double double_a;
//无符号32bit的可能会变成大负数
unsigned int ui_a;
//long float不支持


//以上都是会转化为int的
/////////////////////////////////////////////////////////////////////////

bool bool_a;//lua中支持boolean,所以不直接当成int

char char_a; //和signed char不一样,会转成单字符string




