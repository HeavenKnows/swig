#ifndef __BASIC_TYPE_HPP__
#define __BASIC_TYPE_HPP__

//都是全局变量，且定义在头文件中（似乎应该放在cpp中，并且添加到，i文件中）
int int_a;
short short_a;
long long_a;
signed signed_a;
unsigned unsigned_a;
unsigned short us_a;
unsigned long ul_a;
unsigned char uc_a;
signed char sc_a;
char char_a; //和signed char是否一样
bool bool_a;
//据说，以上都是会转化为int的
float float_a;
double double_a;
//long float不支持


//64bit的可能会被截断


//无符号32bit的可能会变成大负数
unsigned int ui_a;

#endif

//这样的hpp+i文件生成的代码中是丝毫没有这些类型专有的信息的.
