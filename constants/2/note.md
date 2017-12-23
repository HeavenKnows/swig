# note

## .h文件的内容
1. 空

## .i文件的内容

```
%module constants

%{
    #include <constants.hpp>
%}

#define PI 3.14
#define PI_4 PI/4
#define STR "hello world"
#define NEWLINE '\n'
#define FLAGS 0x04 | 0x08 | 0x40

enum months {JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC};

const double c_double = 10.24;

%constant double BLAH = 24.10;

```

## 生成代码结果及分析

```
static swig_lua_attribute swig_SwigModule_attributes[] = {
    { "c_double", _wrap_c_double_get, SWIG_Lua_set_immutable },
    {0,0,0}
};
static swig_lua_const_info swig_SwigModule_constants[]= {
    {SWIG_LUA_CONSTTAB_FLOAT("PI", 3.14)},
    {SWIG_LUA_CONSTTAB_FLOAT("PI_4", 3.14/4)},
    {SWIG_LUA_CONSTTAB_STRING("STR", "hello world")},
    {SWIG_LUA_CONSTTAB_CHAR("NEWLINE", '\n')},
    {SWIG_LUA_CONSTTAB_INT("FLAGS", 0x04|0x08|0x40)},
    {SWIG_LUA_CONSTTAB_INT("JAN", JAN)},
    {SWIG_LUA_CONSTTAB_INT("FEB", FEB)},
    {SWIG_LUA_CONSTTAB_INT("MAR", MAR)},
    {SWIG_LUA_CONSTTAB_INT("APR", APR)},
    {SWIG_LUA_CONSTTAB_INT("MAY", MAY)},
    {SWIG_LUA_CONSTTAB_INT("JUN", JUN)},
    {SWIG_LUA_CONSTTAB_INT("JUL", JUL)},
    {SWIG_LUA_CONSTTAB_INT("AUG", AUG)},
    {SWIG_LUA_CONSTTAB_INT("SEP", SEP)},
    {SWIG_LUA_CONSTTAB_INT("OCT", OCT)},
    {SWIG_LUA_CONSTTAB_INT("NOV", NOV)},
    {SWIG_LUA_CONSTTAB_INT("DEC", DEC)},
    {0,0,0,0,0,0}
};
```
1. swig_module中为空
2. 对于全局的const变量

    * 会生成get函数,不生成set函数;
    * 全局const是attribute,放入swig_SwigModule中;
   
3. 对于%constant

    * 完全不同于const变量，他和以下两种情况是一样的,被当做是constants,放入swig_SwigModule中;
    * 不提供get和set函数;

4. 对于#define

    * 被当做是constants,放入swig_SwigModule中;
    * 不提供get和set函数;
    
5. 对于enum

    * 同样被当做constants,放入swig_SwigModule中;
    * 不提供get和set函数;
    
## 总结:
1. 本质上来讲const定义的实际是变量(只是不允许改变他的值而已),而#define和enum定义的才是真的常量;
2. 所以在生成代码中const是作为attribute存在的,而#define和enum是作为constants存在的;
3. %constant是swig自己的语法，用以定义一个真实的常量;
