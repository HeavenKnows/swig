# note

## .h文件的内容
1. 只在.h文件中包含常量

```C++
#ifndef __CONSTANTS_HPP__
#define __CONSTANTS_HPP__


#define PI 3.14
#define PI_4 PI/4
#define STR "hello world"
#define NEWLINE '\n'
#define FLAGS 0x04 | 0x08 | 0x40

enum months {JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC};

const double c_double = 10.24;


#endif
```

## .i文件的内容
    只包含头文件

## 生成代码结果分析
1. 生成代码中不包含任何针对这些声明的内容;
