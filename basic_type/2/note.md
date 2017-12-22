# note

## .h文件的内容
空

## .i文件的内容
只包含基本类型

```C++
%module basic_type

%{
    #include <basic_type.hpp>
%}

int int_a;
short short_a;
long long_a;
signed signed_a;
unsigned unsigned_a;
unsigned short us_a;
unsigned long ul_a;
unsigned char uc_a;
signed char sc_a; //signed char也会变成lua_Number,也就是int

bool bool_a;
//以上都是会转化为lua_Number的,也就是int

char char_a; //和signed char不一样

float float_a;
double double_a;
//long float不支持

//64bit的可能会被截断


//无符号32bit的可能会变成大负数
unsigned int ui_a; //被强转为int
```

## 生成代码结果分析
1. swig_module为空,这些类型并没有添加到模块信息中;
2. 全部被放入swig_SwigModule的attribute表中了;(也就是走namespace注册流程)
2. 这些全局变量都自动生成了set函数和get函数;
3. C++ --> lua 使用get函数
   这些类型基本上都是转化为lua_Number压入栈中给lua使用;
   **所以这里便是坑,截断,符号位问题都会在这里发生**
4. lua --> C++ 使用set函数
   C++中会吧lua压入栈中的类型强转成所要类型;
5. 需要注意的地方:
   * signed char和unsigned char会被转化为int放入栈中;
   * char被当做单字符string放入栈中;
   * bool被转为int后用pushboolean压入栈中,因为lua支持boolean,否则就直接是int了.
   * float和double也被当做lua_Number了,所以会被截断;  **why????**
