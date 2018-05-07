// This is the header file for fixed point data type

#ifndef POINT17_H_
#define POINT17_H_

#include <iostream>

class Point17
{
private:
    unsigned int val;
    bool ov;  // overflow
    bool uv;  // underflow

public:
    friend std::ostream & operator<<(std::ostream & os, const Point17 & v);
    friend std::ofstream & operator<<(std::ofstream & os, const Point17 & v);  // write binary
    //friend unsigned int operator=(const Point17 & v);
    operator unsigned int() const { return val; };
    double todouble() const;
    Point17 & operator=(float afloat);
    Point17 & operator=(double adouble);
    Point17 & operator=(unsigned int aint);
    Point17 & operator=(int aint);
    Point17 & operator=(const Point17 & another);
    Point17 operator+(const Point17 & adder) const;
    Point17 operator*(const Point17 & multiplier) const;
    Point17 mac(const Point17 & ain, const Point17 & bin);
    void fillbuf(char * pbuf) const;
    void fillbuf(char * pbuf, const unsigned int & mask, const char & offset=0) const;
};


#endif
