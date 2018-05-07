#include "adapter.h"

void setAdapter(int* va, int mode, unsigned int addr)
{
    switch(mode){
        case WRITE_MODE:
            *va = 1;
            break;
        case READ_MODE:
            *va = 0;
            break;
        case TRIG:
            if((*va) & 1) *va = 3;
            else *va = 2;
            break;
        case UNTRIG:
            if((*va) & 1) *va = 1;
            else *va = 0;
            break;
        case BRAM_START_ADDR:
            *(va+1) = addr;
            break;
        case BRAM_BOUND_ADDR:
            *(va+2) = addr;
            break;
        default:
            break;
    }
}

