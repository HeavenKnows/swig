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
