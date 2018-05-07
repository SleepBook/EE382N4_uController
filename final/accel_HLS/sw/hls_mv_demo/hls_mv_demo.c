#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

// macros for DMA control registers offset
#define MM2S_CTRL_REG 0x00
#define MM2S_STAT_REG 0x04
#define MM2S_START_ADDR 0x18
#define MM2S_LEN 0x28

#define S2MM_CTRL_REG 0x30
#define S2MM_STAT_REG 0x34
#define S2MM_DST_ADDR 0x48
#define S2MM_LEN 0x58

// macros for HLS control registers offset
#define HLS_CTRL_REG 0x0
#define HLS_GIE_REG 0x4
#define HLS_LIE_REG 0x8
#define HLS_IS_REG 0xc

#define SIZE 128 // matrix dimension
#define ITER 9 // number of iterations

#define PAGE_SIZE 4096

void mem_set(unsigned int* virtual_addr, int offset, unsigned int val) {
    virtual_addr[offset >> 2] = val;
}

unsigned int mem_get(unsigned int* virtual_addr, int offset) {
    return virtual_addr[offset >> 2];
}

void hls_accel_status(unsigned int* hls_virtual_addr) {
#ifdef DEUG
    unsigned int status = mem_get(hls_virtual_addr, HLS_CTRL_REG);
    printf("HLS accelerator status (0x%08x@0x%02x):", status, HLS_CTRL_REG);
    if(status & 0x01) printf(" start"); else printf(" not started yet");
    if(status & 0x02) printf(" done");
    if(status & 0x04) printf(" idle");
    if(status & 0x08) printf(" ready");
    if(status & 0x08) printf(" auto start");
    printf("\n");

    unsigned int gloal_intr_en = mem_get(hls_virtual_addr, HLS_GIE_REG);
    printf("HLS accelerator Gloal Interrupt Enalble (0x%08x@0x%02x):", gloal_intr_en, HLS_GIE_REG);
    if(global_intr_en & 0x01) printf(" global interrupt enabled"); 
    else printf(" gloal interrupt not enabled");
    printf("\n");

    unsigned int local_intr_en = mem_get(hls_virtual_addr, HLS_LIE_REG);
    printf("HLS accelerator Local Interrupt Enalble (0x%08x@0x%02x):", local_intr_en, HLS_LIE_REG);
    if(local_intr_en & 0x01) printf(" local interrupt enabled"); 
    else printf(" local interrupt not enabled");
    printf("\n");

    unsigned int local_intr_s = mem_get(hls_virtual_addr, HLS_IS_REG);
    printf("HLS accelerator Local Interrupt status (0x%08x@0x%02x):", local_intr_s, HLS_IS_REG);
    if(local_intr_s & 0x01) printf(" ap_done generates an interrupt"); 
    if(local_intr_s & 0x02) printf("ap_ready generates an interrupt");
    printf("\n");
#endif
}

void dma_s2mm_status(unsigned int* dma_virtual_addr) {
#ifdef DEBUG
    unsigned int status = mem_get(dma_virtual_addr, S2MM_STAT_REG);
    printf("Stream to memory-mapped status (0x%08x@0x%02x):", status, S2MM_STAT_REG);
    if(status & 0x00000001) printf(" halted"); else printf(" running");
    if(status & 0x00000002) printf(" idle");
    if(status & 0x00000008) printf(" SGIncld");
    if(status & 0x00000010) printf(" DMAIntErr");
    if(status & 0x00000020) printf(" DMASlvErr");
    if(status & 0x00000040) printf(" DMADecErr");
    if(status & 0x00000100) printf(" SGIntErr");
    if(status & 0x00000200) printf(" SGSlvErr");
    if(status & 0x00000400) printf(" SGDecErr");
    if(status & 0x00001000) printf(" IOC_Irq");
    if(status & 0x00002000) printf(" Dly_Irq");
    if(status & 0x00004000) printf(" Err_Irq");
    printf("\n");
#endif
}

void dma_mm2s_status(unsigned int* dma_virtual_addr) {
#ifdef DEBUG
    unsigned int status = mem_get(dma_virtual_addr, MM2S_STAT_REG);
    printf("Memory-mapped to stream status (0x%08x@0x%02x):", status, MM2S_STAT_REG);
    if(status & 0x00000001) printf(" halted"); else printf(" running");
    if(status & 0x00000002) printf(" idle");
    if(status & 0x00000008) printf(" SGIncld");
    if(status & 0x00000010) printf(" DMAIntErr");
    if(status & 0x00000020) printf(" DMASlvErr");
    if(status & 0x00000040) printf(" DMADecErr");
    if(status & 0x00000100) printf(" SGIntErr");
    if(status & 0x00000200) printf(" SGSlvErr");
    if(status & 0x00000400) printf(" SGDecErr");
    if(status & 0x00001000) printf(" IOC_Irq");
    if(status & 0x00002000) printf(" Dly_Irq");
    if(status & 0x00004000) printf(" Err_Irq");
    printf("\n");
#endif
}

int dma_mm2s_sync(unsigned int* dma_virtual_addr, unsigned int* hls_virtual_addr) {
    unsigned int mm2s_status = mem_get(dma_virtual_addr, MM2S_STAT_REG);
    while(!(mm2s_status & 1 << 12) || !(mm2s_status & 1 << 1)) {
        dma_s2mm_status(dma_virtual_addr);
        dma_mm2s_status(dma_virtual_addr);
        hls_accel_status(hls_virtual_addr);

        mm2s_status = mem_get(dma_virtual_addr, MM2S_STAT_REG);
    }
}

int dma_s2mm_sync(unsigned int* dma_virtual_addr, unsigned int* hls_virtual_addr) {
    unsigned int s2mm_status = mem_get(dma_virtual_addr, S2MM_STAT_REG);
    while(!(s2mm_status & 1 << 12) || !(s2mm_status & 1 << 1)) {
        dma_s2mm_status(dma_virtual_addr);
        dma_mm2s_status(dma_virtual_addr);
        hls_accel_status(hls_virtual_addr);

        s2mm_status = mem_get(dma_virtual_addr, S2MM_STAT_REG);
    }
}

int dma_sync(unsigned int* dma_virtual_addr, unsigned int* hls_virtual_addr) {
    unsigned int mm2s_status = mem_get(dma_virtual_addr, MM2S_STAT_REG);
    unsigned int s2mm_status = mem_get(dma_virtual_addr, S2MM_STAT_REG);
    while(!(s2mm_status & 1 << 12) || !(s2mm_status & 1 << 1)
                || !(mm2s_status & 1 << 12) || !(mm2s_status & 1 << 1)) {
        dma_s2mm_status(dma_virtual_addr);
        dma_mm2s_status(dma_virtual_addr);
        hls_accel_status(hls_virtual_addr);

        s2mm_status = mem_get(dma_virtual_addr, S2MM_STAT_REG);
        mm2s_status = mem_get(dma_virtual_addr, MM2S_STAT_REG);
    }
}

void memdump(void* virtual_addr, int byte_count) {
    char *p = virtual_addr;
    int offset;
    for(offset = 0; offset < byte_count; offset++) {
        printf("%02x", p[offset]);
        if(offset % 4 == 3) printf(" ");
    }
    printf("\n");
}

void hls_start(unsigned int* v_hls) {
    unsigned int data = mem_get(v_hls, HLS_CTRL_REG) & 0x80;
    mem_set(v_hls, HLS_CTRL_REG, data | 0x01);
}

int main() {
    int dh = open("/dev/mem", O_RDWR | O_SYNC);
    unsigned int phy_src_addr = 0x0e000000;
    unsigned int phy_dst_addr = 0x0f000000;

    unsigned int* virtual_dma_addr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, dh, 0x40400000); // mmap of DMA base address
    unsigned int* virtual_hls_addr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, dh, 0x43c00000); // mmap of HLS address
    float* virtual_src_addr = mmap(NULL, 17 * PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, dh, phy_src_addr); // mmap of matrix and vector source address
    float* virtual_dst_addr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, dh, phy_dst_addr); // mmap of vector output address
   
    float a[SIZE][SIZE];
    float b[SIZE];
    float out[SIZE];
    float ref_out[SIZE];

    int i, j, k;

     // generate test matrix A and vector B
    for(i = 0; i < SIZE; i++) {
        for(j = 0; j < SIZE; j++) {
            a[i][j] = ((float)rand())/RAND_MAX;
            virtual_src_addr[i * SIZE + j] = a[i][j];
        }
        b[i] = ((float)rand())/RAND_MAX;
        virtual_src_addr[i + SIZE * SIZE] = b[i];
     }

     // generate reference output to verify
    for(i = 0; i < SIZE; i++) {
        float sum = 0;

        for(j = 0; j < SIZE; j++)
            sum += a[i][j] * b[j];

        ref_out[i] = sum;
    }

    printf("Resetting DMA\n");
    mem_set(virtual_dma_addr, S2MM_CTRL_REG, 4);
    mem_set(virtual_dma_addr, MM2S_CTRL_REG, 4);
    dma_s2mm_status(virtual_dma_addr);
    dma_mm2s_status(virtual_dma_addr);

    printf("Halting DMA\n");
    mem_set(virtual_dma_addr, S2MM_CTRL_REG, 0);
    mem_set(virtual_dma_addr, MM2S_CTRL_REG, 0);
    dma_s2mm_status(virtual_dma_addr);
    dma_mm2s_status(virtual_dma_addr);

    for(i = 0; i < ITER; i++) {
        printf("\n\n/*********************** Begin Test #%d./*********************** \n\n", i);
        printf("Destination Memset \n"); memset(virtual_dst_addr, 3, sizeof(float) * SIZE);  
        printf("Destination memory block: "); memdump(virtual_dst_addr, sizeof(float) * SIZE);

        printf("Starting HLS accelerator with gloal interrupts disaled...\n");
        hls_start(virtual_hls_addr);
        hls_accel_status(virtual_hls_addr);

        /*********************** MM2S ***********************/

        // transfer matrix a
        printf("Writing source address...\n");
        mem_set(virtual_dma_addr, MM2S_START_ADDR, phy_src_addr);
        dma_mm2s_status(virtual_dma_addr);

        printf("Starting MM2S channel with all interrupts disaled...\n");
        mem_set(virtual_dma_addr, MM2S_CTRL_REG, 0x0001);
        dma_mm2s_status(virtual_dma_addr);

        printf("Writing MM2S length...\n");
        mem_set(virtual_dma_addr, MM2S_LEN, sizeof(float) * SIZE * SIZE);
        dma_mm2s_status(virtual_dma_addr);
        hls_accel_status(virtual_hls_addr);

        printf("Wating for MM2S synchronization...\n");
        dma_mm2s_sync(virtual_dma_addr, virtual_hls_addr);

        // transfer vector b
        printf("Writing source address...\n");
        mem_set(virtual_dma_addr, MM2S_START_ADDR, phy_src_addr + sizeof(float) * SIZE * SIZE);
        dma_mm2s_status(virtual_dma_addr);

        printf("Starting MM2S channel with all interrupts disaled...\n");
        mem_set(virtual_dma_addr, MM2S_CTRL_REG, 0x0001);
        dma_mm2s_status(virtual_dma_addr);

        printf("Writing MM2S length...\n");
        mem_set(virtual_dma_addr, MM2S_LEN, sizeof(float) * SIZE);
        dma_mm2s_status(virtual_dma_addr);
        hls_accel_status(virtual_hls_addr);

        printf("Wating for MM2S synchronization...\n");
        dma_mm2s_sync(virtual_dma_addr, virtual_hls_addr);

        /*********************** S2MM ***********************/
        printf("Writing destination address...\n");
        mem_set(virtual_dma_addr, S2MM_DST_ADDR, phy_dst_addr);
        dma_s2mm_status(virtual_dma_addr);

        printf("Starting S2MM channel with all interrupts disabled...\n");
        mem_set(virtual_dma_addr, S2MM_CTRL_REG, 0x0001);
        dma_s2mm_status(virtual_dma_addr);

        printf("Writing S2MM transfer length...\n");
        mem_set(virtual_dma_addr, S2MM_LEN, sizeof(float) * SIZE);
        dma_s2mm_status(virtual_dma_addr);
        hls_accel_status(virtual_hls_addr);

        printf("Wating for MM2S synchronization...\n"); // sync MM2S in case of deadlock
        dma_mm2s_sync(virtual_dma_addr, virtual_hls_addr);

        /*********************** Sync of MM2S and S2MM ***********************/
        // wait for completion
        printf("Wating for MM2S & S2MM synchronization...\n"); 
        dma_sync(virtual_dma_addr, virtual_hls_addr);

        dma_s2mm_status(virtual_dma_addr);
        dma_mm2s_status(virtual_dma_addr);
        hls_accel_status(virtual_hls_addr);

        /*********************** End of Computation ***********************/
        printf("Destination memory block: "); memdump(virtual_dst_addr, sizeof(float) * SIZE);

        // sanity check
        int err = 0;

        for(j = 0; j < SIZE && !err; j++) {
            if(virtual_dst_addr[j] != ref_out[j])
            {
                err++;
                printf("At address %d, ref output is %f, while HLS output is %f.\n", j, ref_out[j], virtual_dst_addr[j]);
            }
        }

        if(err == 0)
            printf("Matrices identical ... Test successful!\r\n");
        else
            printf("Test failed!\r\n");
    }

    return 0;
}


