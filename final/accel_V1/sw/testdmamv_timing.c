#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/time.h>
#include "382dma.h"
#include "adapter.h"

#define MAX_WIDTH  512

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

#define DMA_CTRL   0x40400000
#define ADAP_CTRL  0x43C20000
#define SRC_BASE   0x1FF00000
#define VBRAM_CTRL 0x43C00000
#define VBRAM_BASE 0x43C01000
#define DMAMV_CTRL 0x43C10000

float m[MAX_WIDTH][MAX_WIDTH] = {0};
float v[MAX_WIDTH] = {0};
float r[MAX_WIDTH] = {0};

void float2hex(float f, char * buf)
{
    char * pchar = (char *)&f;
    char val;
    val = pchar[3] >> 4;
    if(0<= val && val <= 9)
        buf[0] = val + '0';
    else
        buf[0] = val + 'A' - 10;
    val = pchar[3] & 0xF;
    if(0<= val && val <= 9)
        buf[1] = val + '0';
    else
        buf[1] = val + 'A' - 10;
    val = pchar[2] >> 4;
    if(0<= val && val <= 9)
        buf[2] = val + '0';
    else
        buf[2] = val + 'A' - 10;
    val = pchar[2] & 0xF;
    if(0<= val && val <= 9)
        buf[3] = val + '0';
    else
        buf[3] = val + 'A' - 10;
    val = pchar[1] >> 4;
    if(0<= val && val <= 9)
        buf[4] = val + '0';
    else
        buf[4] = val + 'A' - 10;
    val = pchar[1] & 0xF;
    if(0<= val && val <= 9)
        buf[5] = val + '0';
    else
        buf[5] = val + 'A' - 10;
    val = pchar[0] >> 4;
    if(0<= val && val <= 9)
        buf[6] = val + '0';
    else
        buf[6] = val + 'A' - 10;
    val = pchar[0] & 0xF;
    if(0<= val && val <= 9)
        buf[7] = val + '0';
    else
        buf[7] = val + 'A' - 10;
    buf[8] = '\0';
}

int main(int argc, char * argv[])
{
    int iter;
    int i, j, idx;
    struct timeval program_start, program_end;
    struct timeval toDMA, tofeedV, tocompute, toreadback;

    gettimeofday(&program_start, NULL);

    if(3 > argc)
    {
        printf("Usage: %s <matrix_float.binary> <result.binary> [#iter]\n", argv[0]);
        return -1;
    }
    else if(3 < argc)
        iter = atoi(argv[3]);
    else
        iter = 1;

    /*
     * Open Phy Mem
     */
    int fd = open("/dev/mem", O_RDWR|O_SYNC);
    if(fd == -1){
        printf("unable to open /dev/mem\n");
        return -8;
    }

    /*
     * DO memory Maping
     */

    unsigned int * dma_ctrl;
    unsigned int * adap_ctrl;
    float * src_base;
    unsigned int * vbram_ctrl;
    float * vbram_base;
    unsigned int * dmamv_ctrl;

    dma_ctrl = (unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            DMA_CTRL & ~MAP_MASK
            );
    //printf("\ndma_ctrl: 0x%08X => %p\n", DMA_CTRL, dma_ctrl);
    adap_ctrl = (unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            ADAP_CTRL & ~MAP_MASK
            );
    //printf("\nadap_ctrl: 0x%08X => %p\n", ADAP_CTRL, adap_ctrl);
    src_base = (float *)mmap(
            NULL,
            256*MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            SRC_BASE & ~MAP_MASK
            );
    //printf("\nsrc_base: 0x%08X => %p\n", SRC_BASE, src_base);
    vbram_ctrl = (unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            VBRAM_CTRL & ~MAP_MASK
            );
    //printf("\nvbram_ctrl: 0x%08X => %p\n", VBRAM_CTRL, vbram_ctrl);
    vbram_base = (float *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            VBRAM_BASE & ~MAP_MASK
            );
    //printf("\nvbram_base: 0x%08X => %p\n", VBRAM_BASE, vbram_base);
    dmamv_ctrl = (unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            DMAMV_CTRL & ~MAP_MASK
            );
    //printf("\ndmamv_ctrl:    0x%08X => %p\n", DMAMV_CTRL, dmamv_ctrl);


    FILE * fin = fopen(argv[1], "rb");
    if(NULL == fin)
    {
        printf("Error: unable to read %s \n", argv[1]);
        return -2;
    }
    char afloat[4];
    fread(afloat, 4, 1, fin);
    const int num_col = *((int *) afloat);
    //printf("Expected Matrix Size %dx%d\n", num_col, num_col);
    const int extended = (num_col % 6) ? num_col + (6 - (num_col % 6)) : num_col;
    //printf("Extended Matrix Size %dx%d\n", extended, extended);
    const int sixrows = 6 * extended;

    for(i = 0; i < extended; i+=6)
    {
        for(idx = 0; idx < 6; ++idx)
        {
            for(j = 0; j < extended; ++j)
            {
                int offset = i * extended + 6*j + idx;
                if(num_col <=i || num_col <= j)
                    src_base[offset] = 0;
                else
                {
                    fread(afloat, 4, 1, fin);
                    src_base[offset] = *((float *) afloat);
                    if(feof(fin))
                    {
                        printf(
                                "Error: %d elements is less than expected (%d elements)\n",
                                i*sixrows+6*j+idx,
                                extended*extended
                              );
                        fclose(fin);
                        return -3;
                    }
                }
            }
        }
    }

    //for(idx = 0; idx < extended * extended; ++idx)
    //    printf("%f\n", src_base[idx]);

    // configue adapter
    setAdapter(adap_ctrl, BRAM_START_ADDR, 0);
    setAdapter(adap_ctrl, BRAM_BOUND_ADDR, 16);
    setAdapter(adap_ctrl, WRITE_MODE, 0);
    setAdapter(adap_ctrl, TRIG, 0);
    setAdapter(adap_ctrl, UNTRIG, 0);

    // DMA 
    //printf("Resetting DMA\n");
    dma_set(dma_ctrl, S2MM_CONTROL_REGISTER, 4);
    dma_set(dma_ctrl, MM2S_CONTROL_REGISTER, 4);
    dma_s2mm_status(dma_ctrl);
    dma_mm2s_status(dma_ctrl);

    //printf("Halting DMA\n");
    dma_set(dma_ctrl, S2MM_CONTROL_REGISTER, 0);
    dma_set(dma_ctrl, MM2S_CONTROL_REGISTER, 0);
    dma_s2mm_status(dma_ctrl);
    dma_mm2s_status(dma_ctrl);

    // DMA Timing Interval //
    gettimeofday(&toDMA, NULL);
    //printf("Writing source address...\n");
    dma_set(dma_ctrl, MM2S_START_ADDRESS, SRC_BASE); // Write source address
    //printf("this is the status after src address\n");
    dma_mm2s_status(dma_ctrl);

    //printf("Starting MM2S channel with all interrupts masked...\n");
    dma_set(dma_ctrl, MM2S_CONTROL_REGISTER, 0xf001);
    dma_mm2s_status(dma_ctrl);

    //printf("Writing MM2S transfer length...\n");
    dma_set(dma_ctrl, MM2S_LENGTH, sizeof(float)*extended*extended);
    //printf("mm2s length setting\n");
    dma_mm2s_status(dma_ctrl);

    //printf("Waiting for MM2S synchronization...\n");
    dma_mm2s_sync(dma_ctrl);
    
    //printf("DMA Transfer Done\n");
    gettimeofday(&tofeedV, NULL);

    //printf("DMA time is %ld\n", DMA_time);

    // feed vector bram via lite2hbbram
    const float init_val = 1.0 / num_col;
    for(idx = 0; idx < 6; ++idx)
    {
        vbram_base[idx] = init_val;
    }
    for(i = 6, idx = 0; i <= num_col; i += 6, ++idx)
    {
        vbram_ctrl[0] = (idx << 8) | 0x00000011;
    }
    if(num_col != i)
    {
        for(j = i % 6; j < 6; ++j)
            vbram_base[j] = 0;
        vbram_ctrl[0] = (idx << 8) | 0x00000011;
    }
    gettimeofday(&tocompute, NULL);
    //printf("Vector feed time is %ld\n", vector_feed_time);

    //printf("Vector Transfer Done\n");

    // Computation starts from here

    // trigger the mv module to compute
    *dmamv_ctrl = (iter << 16) | (num_col << 4) | 0x00000001;
    // wait until computation finish
    while((*dmamv_ctrl)&0x00000001);
    //printf("Computation time is %ld\n", comp_time);
    gettimeofday(&toreadback, NULL);


    //printf("Computation Done\n");

    // read out the result
    unsigned int ctrl_rd = 0x00020001;
    if(iter % 2)
        ctrl_rd = 0x00020001;
    else
        ctrl_rd = 0x00000001;
    for(i = 0; i < num_col; i+=6)
    {
        *vbram_ctrl = ctrl_rd;
        for(idx = 0; idx < 6; ++idx)
        {
            r[i+idx] = vbram_base[idx];
        }
        ctrl_rd += 0x00000100;  // increase memory index
    }
    
    munmap(dma_ctrl, MAP_SIZE);
    munmap(adap_ctrl, MAP_SIZE);
    munmap(src_base, 256*MAP_SIZE);
    munmap(vbram_ctrl, MAP_SIZE);
    munmap(vbram_base, MAP_SIZE);
    munmap(dmamv_ctrl, MAP_SIZE);

    close(fd);

    FILE * fout = fopen(argv[2], "wb");
    if(NULL == fout)
    {
        printf("Error: unable to open %s\n", argv[3]);
        return -7;
    }
    fwrite((void*)(&num_col), sizeof(num_col), 1, fout);
    fwrite((void*)(r), sizeof(r[0]), num_col, fout);
    fclose(fout);

    gettimeofday(&program_end, NULL);

    long DMA_time = tofeedV.tv_sec*1000000 + tofeedV.tv_usec - toDMA.tv_sec*1000000 - toDMA.tv_usec;
    long vector_feed_time = tocompute.tv_sec*1000000 + tocompute.tv_usec - tofeedV.tv_sec*1000000 - tofeedV.tv_usec;
    long comp_time = toreadback.tv_sec*1000000 + toreadback.tv_usec - tocompute.tv_sec*1000000 - tocompute.tv_usec;
    long total_time = program_end.tv_sec*1000000 + program_end.tv_usec - program_start.tv_sec*1000000 - program_start.tv_usec;
    printf("DMA Time: %ld\n", DMA_time);
    printf("Vector feedin time: %ld\n", vector_feed_time);
    printf("Computation time: %ld\n", comp_time);
    printf("Total time: %ld\n", total_time);

    return 0;
}
