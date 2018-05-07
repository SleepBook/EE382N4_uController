// This is the file to offer basic fixed point arithematics
#include <iostream>
#include <fstream>
#include <type_traits>
#include "point17.hpp"

std::ostream & operator<<(std::ostream & os, const Point17 & v)
{
    char * pchar = (char *) &(v.val);
    char tmp;
    int idx;

    // convert value to floating point

    os << v.todouble();

    os << " 0x";
    tmp = (pchar[2] & 0x0F);
    if(0 <= tmp && tmp <= 9)
        os << (char)(tmp + '0');
    else
        os << (char)(tmp - 10 + 'A');
    tmp = (pchar[1] & 0xF0) >> 4;
    if(0 <= tmp && tmp <= 9)
        os << (char)(tmp + '0');
    else
        os << (char)(tmp - 10 + 'A');
    tmp = (pchar[1] & 0x0F);
    if(0 <= tmp && tmp <= 9)
        os << (char)(tmp + '0');
    else
        os << (char)(tmp - 10 + 'A');
    tmp = (pchar[0] & 0xF0) >> 4;
    if(0 <= tmp && tmp <= 9)
        os << (char)(tmp + '0');
    else
        os << (char)(tmp - 10 + 'A');
    tmp = (pchar[0] & 0x0F);
    if(0 <= tmp && tmp <= 9)
        os << (char)(tmp + '0');
    else
        os << (char)(tmp - 10 + 'A');

    if(v.ov)
        os << " (OVERFLOW) ";
    if(v.uv)
        os << " (UNDERFLOW) ";

    return os;
}

std::ofstream & operator<<(std::ofstream & os, const Point17 & v)
{
    unsigned int value = v.val;

    os.write((char*)&value, sizeof(unsigned int));
    //os << value;

    return os;
}

//unsigned int std::make_unsigned<int>::type::operator=(const Point17 & v)
//{
//    return v.val;
//}

//unsigned int Point17::operator unsigned int()
//{
//    return val;
//}

Point17 & Point17::operator=(float afloat)
{
    float copy = afloat;
    unsigned int bit_mask = 0x00010000;

    if(1 <= copy)
        ov = true;
    else
        ov = false;
    // pick fraction
    while(1 <= copy)
        copy -= 1;

    val = 0;
    while(bit_mask)
    {
        copy *= 2;
        if(1 <= copy)
        {
            val |= bit_mask;
            copy -= 1;
        }
        bit_mask >>= 1;
    }

    if(0 != copy)
        uv = true;
    else
        uv = false;

    return *this;
}

Point17 & Point17::operator=(double adouble)
{
    double copy = adouble;
    unsigned int bit_mask = 0x00010000;

    if(1 <= copy)
        ov = true;
    else
        ov = false;
    // pick fraction
    while(1 <= copy)
        copy -= 1;

    val = 0;
    while(bit_mask)
    {
        copy *= 2;
        if(1 <= copy)
        {
            val |= bit_mask;
            copy -= 1;
        }
        bit_mask >>= 1;
    }

    if(0 != copy)
        uv = true;
    else
        uv = false;

    return *this;
}

Point17 & Point17::operator=(unsigned int aint)
{
    if(aint & ~0x0001FFFF)
        ov = true;
    else
        ov = false;
    uv = false;
    val = aint & 0x0001FFFF;

    return *this;
}

Point17 & Point17::operator=(int aint)
{
    if(aint & ~0x0001FFFF)
        ov = true;
    else
        ov = false;
    uv = false;
    val = aint & 0x0001FFFF;

    return *this;
}

Point17 & Point17::operator=(const Point17 & another)
{
    ov = another.ov;
    uv = another.uv;
    val = another.val;

    return *this;
}

Point17 Point17::operator+(const Point17 & adder) const
{
    bool carry = false;
    unsigned int bit_mask = 0x00000001;

    Point17 res;

    res.val = 0;
    res.uv = false;
    for(; bit_mask < 0x00020000; bit_mask <<= 1)
    {
        if(carry)
        {
            if(val & bit_mask)  // this val has 1 on the bit
            {
               if(adder.val & bit_mask)  // another val has 1
                   res.val |= bit_mask;
            }
            else if(!(adder.val & bit_mask))
            {
                res.val |= bit_mask;
                carry = false;
            }
        }
        else
        {
            if(val & bit_mask)
            {
                if(adder.val & bit_mask)
                    carry = true;
                else
                    res.val |= bit_mask;
            }
            else if(adder.val & bit_mask)
            {
                res.val |= bit_mask;
            }
        }

    }

    if(carry)
        res.ov = true;
    else
        res.ov = false;

    return res;
}

Point17 Point17::operator*(const Point17 & multiplier) const
{
    double adouble;
    Point17 res;

    adouble = this->todouble() * multiplier.todouble();

    res = adouble;

    return res;
}

Point17 Point17::mac(const Point17 & ain, const Point17 & bin)
{
    double adouble;
    
    adouble = ain.todouble() * bin.todouble() + this->todouble();

    *this = adouble;

    return *this;
}

double Point17::todouble() const
{
    char * pchar = (char *) &(val);
    double adouble, pow2;
    char tmp;
    int idx;

    // convert value to floating point
    pow2 = 1.0/2;
    adouble = 0;
    if(pchar[2] & 0x01)
        adouble += pow2;
    pow2 /= 2;
    for(tmp = pchar[1], idx = 0; idx < 8; ++idx)
    {
        if(tmp & 0x80)
            adouble += pow2;
        pow2 /= 2;
        tmp <<= 1;
    }
    for(tmp = pchar[0], idx = 0; idx < 8; ++idx)
    {
        if(tmp & 0x80)
            adouble += pow2;
        pow2 /= 2;
        tmp <<= 1;
    }

    return adouble;
}

void Point17::fillbuf(char * pbuf) const
{
    char * pchar = (char*)(&val);
    if(pbuf)
    {
        for(int i = 0; i < 4; ++i)
            pbuf[i] = pchar[i];
    }
}

void Point17::fillbuf(char * pbuf, const unsigned int & mask, const char & offset /*=0*/) const
{
    unsigned int value = (val << offset) & mask;
    char * pv = (char*)(&value);
    char * pm = (char*)(&mask);
    if(pbuf)
    {
        for(int i = 0; i < 4; ++i)
        {
            pbuf[i] &= ~pm[i];
            pbuf[i] |= pv[i];
        }
    }
}

