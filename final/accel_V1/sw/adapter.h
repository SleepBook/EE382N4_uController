#ifndef _ADAP_H_
#define _ADAP_H_

void setAdapter(int* va, int mode, unsigned int addr);

enum{
    WRITE_MODE,
    READ_MODE,
    BRAM_START_ADDR,
    BRAM_BOUND_ADDR,
    TRIG, 
    UNTRIG
};

#endif
