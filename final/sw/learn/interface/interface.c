#include <stdio.h>
#include "382dma.h"

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE)

void adapter_set(int* va, int mode, unsigned int addr)
{
    switch(mode){
        case WRITE_MODE:
            *va = 1;
            break;
        case READ_MODE:
            *va = 0;
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


int main() {
    int dh = open("/dev/mem", O_RDWR | O_SYNC); // Open /dev/mem which represents the whole physical memory
    unsigned int* va_dma_cntl = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, DMA_ADDR); // Memory map AXI Lite register block
    unsigned int* va_src_addr  = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, SRC_ADDR); // Memory map source address
    unsigned int* va_dst_addr  = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, DST_ADDR); // Memory map source address
    unsigned int* va_bram_addr =  mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, BRAM_ADDR); 
    unsigned int* va_bram_cntl =  mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, BRAM_CNTL); 
    unsigned int* va_adapter_cntl =  mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, ADAP_CNTL); 

    //initializing 
    printf("Resetting DMA\n");
    dma_set(va_dma_cntl, S2MM_CONTROL_REGISTER, 4);
    dma_set(va_dma_cntl, MM2S_CONTROL_REGISTER, 4);
    dma_s2mm_status(va_dma_cntl);
    dma_mm2s_status(va_dma_cntl);

    printf("Halting DMA\n");
    dma_set(va_dma_cntl, S2MM_CONTROL_REGISTER, 0);
    dma_set(va_dma_cntl, MM2S_CONTROL_REGISTER, 0);
    dma_s2mm_status(va_dma_cntl);
    dma_mm2s_status(va_dma_cntl);

    printf("Setting up adapter\n");
    adapter_set(va_adapter_cntl, WRITE_MODE, 0);

    printf("setting up bram cntl\n");
    *va_bram_cntl = 0x00000001;  // trigger the reading of the bram[0]

   
    //write src data
    int i;
    for(i=0;i<72;i++){
        va_src_addr[i]= i;
    }

    for(i=0;i<72;i++){
        printf("%d ", va_src_addr[i]);
    }
    printf("\n");


    printf("Writing source address...\n");
    dma_set(va_dma_cntl, MM2S_START_ADDRESS, SRC_ADDR); // Write source address
    printf("this is the status after src address\n");
    dma_mm2s_status(va_dma_cntl);

    printf("Starting MM2S channel with all interrupts masked...\n");
    dma_set(va_dma_cntl, MM2S_CONTROL_REGISTER, 0xf001);
    dma_mm2s_status(va_dma_cntl);

    printf("Writing MM2S transfer length...\n");
    dma_set(va_dma_cntl, MM2S_LENGTH, CP_LEN);
    printf("mm2s length setting\n");
    dma_mm2s_status(va_dma_cntl);

    printf("Waiting for MM2S synchronization...\n");
    dma_mm2s_sync(va_dma_cntl);


    //readback the data
    for(i=0;i<72;i++){
        printf("%d ",va_bram_addr[i]);
    }
    printf("\n");


    /*

    //read from BRAM test
    //prepare the data(this can be commented to let it happen through dma write

    printf("setting up bram cntl\n");
    //last bit trig
    //last but one bit 1/0 w/r
    //rest are address
    *va_bram_cntl = 0x00000001;  // trigger the reading of the bram[0]

   
    //write src data
    for(i=0;i<72;i++){
        va_bram_addr[i]= i;
    }

    for(i=0;i<72;i++){
        printf("%d ", va_bram_addr[i]);
    }
    printf("\n");

    //setting up the bram_init

    adapter_set(va_adapter_cntl, READ_MODE, 0);
    adapter_set(va_adapter_cntl, BRAM_START_ADDR, 0);
    adapter_set(va_adapter_cntl, BRAM_BOUND_ADDR, 2);

    //initialization
    dma_set(va_dma_cntl, S2MM_CONTROL_REGISTER, 4);
    dma_s2mm_status(va_dma_cntl);
    dma_set(va_dma_cntl, S2MM_CONTROL_REGISTER, 0);
    dma_s2mm_status(va_dma_cntl);

    dma_set(va_dma_cntl, S2MM_DESTINATION_ADDRESS, DST_ADDR); // Write destination address
    dma_s2mm_status(va_dma_cntl);

    printf("Starting S2MM channel with all interrupts masked...\n");
    dma_set(va_dma_cntl, S2MM_CONTROL_REGISTER, 0xf001);
    dma_s2mm_status(va_dma_cntl);

    dma_set(va_dma_cntl, S2MM_LENGTH, CP_LEN);
    printf("s2mm length setting\n");
    dma_s2mm_status(va_dma_cntl);

    printf("Waiting for MM2S synchronization...\n");
    dma_mm2s_sync(va_dma_cntl);

    printf("Waiting for S2MM sychronization...\n");
    dma_s2mm_sync(va_dma_cntl); // If this locks up make sure all memory ranges are assigned under Address Editor!

    dma_s2mm_status(va_dma_cntl);

    //check the readback 
    for(i=0;i<72;i++){
        printf("%d ", va_dst_addr[i]);
    }
    printf("\n");
    */

    return 0;
}
