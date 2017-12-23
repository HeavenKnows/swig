# SWIG 笔记 for lua

-------------------------------------------------------------------------------------
--------------------------------------------通用部分----------------------------------
## Basics

----------------------------------------------------------------------------------------

1. run
    swig [ options ] filename

```
$ swig [-c++] -lua -o example_wrap.c example.i 
//example.i要放在后面,否则识别不了
$ gcc -fPIC -I/usr/include/lua -c example_wrap.c -o example_wrap.o
$ gcc -fPIC -c example.c -o example.o
$ gcc -shared -I/usr/include/lua -L/usr/lib/lua example_wrap.o example.o -o example.so
```

----------------------------------------------------------------------------------------

2. 输入文件
典型写法:

```c++
%module mymodule 
%{
#include "myheader.h"
%}
// Now list ANSI C/C++ declarations
int foo;
int bar(int x);
...
```

---------------------------------------------------------------------------------------

3. 预处理器
* #include 语句被忽略,除非命令行选项 -includeall 被打开;   ????
The reason for disabling includes is that SWIG is sometimes used to process raw C header files. In this case, you usually only want the extension module to include functions in the supplied header file rather than everything that might be included by that header file (i.e., system headers, C library functions, etc.).

----------------------------------------------------------------------------------------

4. SWIG 指示符
* 以 % 开头
* 通常不能直接写在C的头文件中,但是有办法写进去

```c++
/* header.h  --- Some header file */

/* SWIG directives -- only seen if SWIG is running */ 
#ifdef SWIG

%module foo

#endif
```

-----------------------------------------------------------------------------------------

5. 语法分析器的局限性 parser limitation

大部分局限是关于复杂类型的声明和C++高级特性;

* a.非常规声明;

```c++
/* extern 的位置不典型 */
const int extern Number;

/* Extra declarator grouping */
Matrix (foo);    // A global variable               ??????????

/* Extra declarator grouping in parameters */
void bar(Spam (Grok)(Doh));                         //??????
```

* b.不要用SWIG处理   .c  .cpp  .cxx 源文件,因为局部的声明和定义会被忽略,除非他的声明已经被解析过了;

```c++
/* bar 不会被解析,除非 foo 已经被定义,且bar的声明已经被解析 */
int foo::bar(int) {
    ... whatever ...
}
```

* c.高级特性,如嵌套的class未被支持

跳过解析错误:
```c++
#ifndef SWIG
... some bad declarations ...
#endif
```
------------------------------------------------------------------------------------------

## 封装简单的 C 声明
```c++
%module example

%inline %{
extern double sin(double x);
extern int strcmp(const char *, const char *);
extern int Foo;
%}
#define STATUS 50
#define VERSION "1.1"
```
但是因为语言,运行环境,语意的微小差异,上面的方法可能会不行

1. 基本类型
C++中会转化为integer的类型:(C++ --> 其他语言，因为其他语言可能没有这些类型，但是都有integer）
* int
* short
* long
* unsigned
* signed
* unsigned short
* unsigned long
* unsigned char
* signed char
* bool

使用64bit数可能会被截断;
32bit无符号数可能变成大负数;
所以int和所有的字符型不会出错;

float和double被映射为目标语言的float(通常长度和C里的double一样);
long double不支持;

**通常char类型被映射为一个字符的字符串,\0结尾**
char *类型被处理为\0结尾的8bit字符串,不支持中间有\0的二进制数据;
支持unicode和宽字符;（服务器通常只有utf-8）

2. 全局变量
**通常会自动生成get和set方法,使脚本语言可以直接使用面向对象的方式访问,如a.b = 10**
看swig生成代码中也是这样；

3. 常量 constants
常量被当做只读变量;
可以用#define, enum, 或者%constant指令符定义
```c++
#define PI            3.14159         // A Floating point constant
#define S_CONST       "hello world"   // A string constant
#define NEWLINE       '\n'            // Character constant

enum boolean {NO=0, YES=1};
enum months {JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC};
%constant double BLAH = 42.37;
#define PI_4 PI/4
```
**这里#define和C++里会有一些区别,不限于下面一条**
```c++
#define F_CONST (double) 5            //强制转换会被忽略
```

常量表达式被允许,但是swig不计算他们,而是直接传递给输出的C++文件,让他们计算,swig做一个有限的类型检查;

**最好不要把enum原始定义写在swig的input文件中,包括#include的头文件和%{ %}中**
For enumerations, it is critical that the original enum definition be included somewhere in the interface file (either in a header file or in the %{ %} block). SWIG only translates the enumeration into code needed to add the constants to a scripting language. It needs the original enumeration declaration in order to get the correct enum values as assigned by the C compiler.

%constant对于指针类型或者复杂数据类型很有用,但通常只用于定义未出现在头文件中得常量数据;

**函数的const参数和const返回值,会被忽略**

4. char* 的坑
**字符串从脚本传到C++的char*时,这个指针通常指向脚本解释器中的一段字符串数据,所以不要编辑这个数据**
主要发生在编辑字符串的函数,如
char *strcat(char *s, const char *t)
虽然会被SWIG封装,但是行为是未定义的,程序会crash;
**不要依赖char*,除非是const的输入**

----------------------------------------------------------------------------------------------

## 指针和复杂对象

1. 简单指针
- 完全支持基础类型的指针;
- SWIG只是将pointer编码传给脚本;
- 空指针被映射为"NULL"字符串,或包含类型的0编码;
- 所有指针被SWIG处理为不透明对象,传递给脚本后不能解引用,只能作为代表该对象的一个ID;
- 所以在脚本中不要直接操控这个指针;
**SWIG不会将指针映射为高级对象,如关联数组或链表**
**比如 int* 不会被SWIG(理解为)转化为int数组**

2. 运行时指针类型检查
- 为了允许在脚本中操控指针,"扩展模块"跳过了C/C++编译器的编译时类型检查,为了避免错误,指针名被加上类型标记,用于运行时类型检查;
- NULL指针检查交给了C/C++程序;

3. 派生类型 , 结构体 , 类
**都看做指针**
- 通过C/C++模块来操作数据,在脚本中只当做一个ID;

4. 未定义的类型
- SWIG遇到没有声明的数据类型,全部当做结构体或者类,并看做指针;
**坑**
```c++
void foo(size_t num);
```

如果在SWIG中没有看到 size_t 的声明, 生成的封装就会期望得到一个size_t*; 
脚本中这样使用就会报错:
```
foo(40);
TypeError: expected a _p_size_t.
```
解决办法就是确保使用typedef声明了该类型;

5. typedef
```c++
%{
/* 被包含到了接口文件中 */
typedef unsigned int size_t;
%}
/* SWIG知道,但是不会写到生成的接口文件中 */
typedef unsigned int size_t;
```
或者
```
%inline %{
typedef unsigned int size_t;
%}
```

通常我们需要包含一个专门的type头文件:
```
%module example
%import "sys/types.h"   //看清楚是%import, 不是#include
//但是这种方式不一定管用,因为系统头文件可能依靠各种非标准C的扩展编码
```
这种情况下,需要-includeall
$ swig -I/usr/include -includeall example.i

-------------------------------------------------------------------------------------

## 其他

1. 值传递 pass struct by value

如:
```c++
double dot_product(Vector a, Vector b);
```
SWIG将其转化为:
```c++
double wrap_dot_product(Vector *a, Vector *b) {
    Vector x = *a;
    Vector y = *b;
    return dot_product(x, y);   
    //因为这个透明处理,所以调用时意识不到实际传的是指针;
    //调用时使用的vector对象实际是某个函数return by value的,
    // 返回值实际上也是指针,但是同样意识不到,然后这里再使用它
}
```

2. 值返回 return by value

如:
```c++
Vector cross_product(Vector v1, Vector v2);
```
SWIG将其转化为:
```c++
Vector *wrap_cross_product(Vector *v1, Vector *v2) {
        Vector x = *v1;
        Vector y = *v2;
        Vector *result = new Vector(cross_product(x, y)); 
        //使用默认拷贝构造,也就是说vector类型必须有默认 constructor
        return result;
}
```
**SWIG实际上创建了局部对象,传给原函数,返回值对象保存到堆中,最后返回其指针,这个对象需要用户自行销毁????????如果意识不到这些隐式的内存分配,就会导致内存泄漏**  
尽管如此,垃圾回收机制????  
有用吗?????

3. 连接结构体变量

```c++
//当结构体变量作为全局变量或者类成员时,要从脚本中访问:
Vector unit_i;

//SWIG做如下处理:
Vector *unit_i_get() {
  return &unit_i;
}

//在脚本那边只能通过指针进行结构体的拷贝构造,
//并不能对结构体内的元素进行赋值操作,
//所以此结构体必须有正确的拷贝构造函数
void unit_i_set(Vector *value) {
  unit_i = *value;
}
```

4. 连接char*

```c++
//全局变量
char *foo;//全局区只是一个指针,具体内容应该在堆

//SWIG这样访问他
void foo_set(char *value) {
  if (foo) delete [] foo;
  foo = new char[strlen(value)+1];
  strcpy(foo, value);
}
//所以每次赋值都进行了一次 空间释放 和 申请;
//感觉比较低效
//最后堆中的数据不需要了,谁来销毁?
```
解决办法:  
a. %immutable该变量,使其不能被set;  
b. 自己写一个函数来赋值,如下:
```c++
//注意写法
%inline 
%{
  void set_foo(char *value) {
    strncpy(foo, value, 50);
  }
%}
//之后只能以 **函数方式** 来修改变量
```

**大坑1:**
```c++
//这种变量,在脚本中是不能给他赋值的
//因为SWIG是通过free或delete释放掉原空间再malloc或new的,而原始空间并不是通过这种方式产生的,所以释放会报错
char *VERSION = "1.0";
```
解决方法:  
a. %immutable
b. 手写设置函数
c. 配置映射表
d. 使用array方式来写
```c++
char VERSION[64] = "1.0";
//array这种写法SWIG是怎么处理的?????见下一条
```

**大坑2:**
```c++
const char *foo = "Hello World\n";
//SWIG仍会生成set和get
//SWIG在set他的时候,不释放原始空间,而是new新空间赋值,再改变指针指向新空间
//所以会导致**内存泄漏**
```

5. 数组array

**默认为只读变量**
```c++
int foobar(int a[40]);
void grok(char *argv[]);
void transpose(double a[20][20]);

int [10];         // Maps to int *
int [10][20];     // Maps to int (*)[20]
int [10][20][30]; // Maps to int (*)[20][30]

//被处理为:  (降维,指向低一维的数组的指针,不同于多重指针)
int foobar(int *a);
void grok(char **argv);
void transpose(double (*a)[20]);

int *;
int (*)[20];
int (*)[20][30];
```
数组默认为只读变量,那么如何改变数组元素呢?  
只能手写函数了:
```c++
%inline 
%{
void a_set(int i, int j, int val) {
  a[i][j] = val;
}
int a_get(int i, int j) {
  return a[i][j];
}
%}

// Some array helpers
//动态创建不同大小的数组
%inline %{
  /* Create any sort of [size] array */
  int *int_array(int size) {
    return (int *) malloc(size*sizeof(int));
  }
  /* Create a two-dimension array [size][10] */
  int (*int_array_10(int size))[10] {
    return (int (*)[10]) malloc(size*10*sizeof(int));
  }
%}
```

**char数组被特殊对待:**
```c++
char pathname[256];

//生成:
char *pathname_get() {
  return pathname;
}

void pathname_set(char *value) {
  strncpy(pathname, value, 256);
}
//脚本语言的string可以直接存到这种数组里
```

6. 创建只读变量

法一:
```c++
// File : interface.i

int a;       // Can read/write
%immutable;
int b, c, d;   // Read only variables
%mutable;
double x, y;  // read/write
```
法二:
```C++
%immutable x;                   // Make x read-only
...
double x;                       // Read-only (from earlier %immutable directive)
double y;                       // Read-write
...
```
%mutable 和 %immutable 是用 %feature 定义的
```c++
#define %immutable   %feature("immutable")
#define %mutable     %feature("immutable", "")
```
让所有的封装都只读:
```c++
%immutable;                     // Make all variables read-only
%feature("immutable", "0") x;   // 除了 x, read/write
...
double x;
double y;
double z;
...
```
当然也可以用const.




====================================SWIG  and  Lua====================================





