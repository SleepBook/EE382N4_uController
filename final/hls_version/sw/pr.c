/** * Proof of concept offloaded memcopy using AXI Direct Memory Access v7.1 */#include <stdio.h>#include <unistd.h>#include <fcntl.h>#include <termios.h>#include <stdlib.h>#include <sys/mman.h>#define MM2S_CONTROL_REGISTER 0x00#define MM2S_STATUS_REGISTER 0x04#define MM2S_START_ADDRESS 0x18#define MM2S_LENGTH 0x28#define S2MM_CONTROL_REGISTER 0x30#define S2MM_STATUS_REGISTER 0x34#define S2MM_DESTINATION_ADDRESS 0x48#define S2MM_LENGTH 0x58#define HLS_CONTROL_REGISTER 0x0#define HLS_GIE_REGISTER 0x4#define HLS_LIE_REGISTER 0x8#define HLS_IS_REGISTER 0xc#define SIZE 128unsigned int dma_set(unsigned int* dma_virtual_address, int offset, unsigned int value) {    dma_virtual_address[offset>>2] = value;}unsigned int dma_get(unsigned int* dma_virtual_address, int offset) {    return dma_virtual_address[offset>>2];}void hls_accel_status(unsigned int* hls_virtual_address) {    unsigned int status = dma_get(hls_virtual_address, HLS_CONTROL_REGISTER);    printf("HLS accerlerator status (0x%08x@0x%02x):", status, HLS_CONTROL_REGISTER);    if (status & 0x01) printf(" start"); else printf(" not start yet");    if (status & 0x02) printf(" done");     if (status & 0x04) printf(" idle");    if (status & 0x08) printf(" ready");    if (status & 0x80) printf(" auto restart");    printf("\n");    unsigned int global_intr_en = dma_get(hls_virtual_address, HLS_GIE_REGISTER);    printf("HLS accerlerator Global Interrupt Enable (0x%08x@0x%02x):", global_intr_en, HLS_GIE_REGISTER);    if(global_intr_en & 0x01) printf(" global interrupt enabled"); else printf(" global interrupt not enabled");    printf("\n");    unsigned int local_intr_en = dma_get(hls_virtual_address, HLS_LIE_REGISTER);    printf("HLS accerlerator Local Interrupt Enable (0x%08x@0x%02x):", local_intr_en, HLS_GIE_REGISTER);    if(local_intr_en & 0x01) printf(" ap_done interrupt enabled");    if(local_intr_en & 0x02) printf(" ap_ready interrupt enabled");    printf("\n");    unsigned int local_intr_s = dma_get(hls_virtual_address, HLS_IS_REGISTER);    printf("HLS accerlerator Local Interrupt Status (0x%08x@0x%02x):", local_intr_s, HLS_IS_REGISTER);    if(local_intr_s & 0x01) printf(" ap_done generates an interrupt");    if(local_intr_s & 0x02) printf(" ap_ready generates an interrupt");    printf("\n");}void dma_s2mm_status(unsigned int* dma_virtual_address) {    unsigned int status = dma_get(dma_virtual_address, S2MM_STATUS_REGISTER);    printf("Stream to memory-mapped status (0x%08x@0x%02x):", status, S2MM_STATUS_REGISTER);    if (status & 0x00000001) printf(" halted"); else printf(" running");    if (status & 0x00000002) printf(" idle");    if (status & 0x00000008) printf(" SGIncld");    if (status & 0x00000010) printf(" DMAIntErr");    if (status & 0x00000020) printf(" DMASlvErr");    if (status & 0x00000040) printf(" DMADecErr");    if (status & 0x00000100) printf(" SGIntErr");    if (status & 0x00000200) printf(" SGSlvErr");    if (status & 0x00000400) printf(" SGDecErr");    if (status & 0x00001000) printf(" IOC_Irq");    if (status & 0x00002000) printf(" Dly_Irq");    if (status & 0x00004000) printf(" Err_Irq");    printf("\n");}void dma_mm2s_status(unsigned int* dma_virtual_address) {    unsigned int status = dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);    printf("Memory-mapped to stream status (0x%08x@0x%02x):", status, MM2S_STATUS_REGISTER);    if (status & 0x00000001) printf(" halted"); else printf(" running");    if (status & 0x00000002) printf(" idle");    if (status & 0x00000008) printf(" SGIncld");    if (status & 0x00000010) printf(" DMAIntErr");    if (status & 0x00000020) printf(" DMASlvErr");    if (status & 0x00000040) printf(" DMADecErr");    if (status & 0x00000100) printf(" SGIntErr");    if (status & 0x00000200) printf(" SGSlvErr");    if (status & 0x00000400) printf(" SGDecErr");    if (status & 0x00001000) printf(" IOC_Irq");    if (status & 0x00002000) printf(" Dly_Irq");    if (status & 0x00004000) printf(" Err_Irq");    printf("\n");}int dma_mm2s_sync(unsigned int* dma_virtual_address, unsigned int* hls_virtual_address) {    unsigned int mm2s_status =  dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);    while(!(mm2s_status & 1<<12) ||             !(mm2s_status & 1<<1) ){        dma_s2mm_status(dma_virtual_address);        dma_mm2s_status(dma_virtual_address);        hls_accel_status(hls_virtual_address);        mm2s_status =  dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);    }}int dma_s2mm_sync(unsigned int* dma_virtual_address, unsigned int* hls_virtual_address) {    unsigned int s2mm_status = dma_get(dma_virtual_address, S2MM_STATUS_REGISTER);    while(!(s2mm_status & 1<<12) ||             !(s2mm_status & 1<<1)){        dma_s2mm_status(dma_virtual_address);        dma_mm2s_status(dma_virtual_address);        hls_accel_status(hls_virtual_address);        s2mm_status = dma_get(dma_virtual_address, S2MM_STATUS_REGISTER);    }}int dma_sync(unsigned int* dma_virtual_address, unsigned int* hls_virtual_address) {    unsigned int s2mm_status = dma_get(dma_virtual_address, S2MM_STATUS_REGISTER);    unsigned int mm2s_status =  dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);    while(!(s2mm_status & 1<<12) || !(s2mm_status & 1<<1) || !(mm2s_status & 1<<12) || !(mm2s_status & 1<<1)){        dma_s2mm_status(dma_virtual_address);        dma_mm2s_status(dma_virtual_address);        hls_accel_status(hls_virtual_address);        s2mm_status = dma_get(dma_virtual_address, S2MM_STATUS_REGISTER);        mm2s_status =  dma_get(dma_virtual_address, MM2S_STATUS_REGISTER);    }}/*int hls_accel_sync(unsigned int* dma_virtual_address, unsigned int* hls_virtual_address) {    unsigned int hls_status =  dma_get(dma_virtual_address, HLS_CONTROL_REGISTER);    while(!(hls_status & 1<<2) ){        dma_s2mm_status(dma_virtual_address);        dma_mm2s_status(dma_virtual_address);        hls_accel_status(hls_virtual_address);        hls_status =  dma_get(hls_virtual_address, HLS_CONTROL_REGISTER);    }}*/void memdump(void* virtual_address, int byte_count) {    char *p = virtual_address;    int offset;    for (offset = 0; offset < byte_count; offset++) {        printf("%02x", p[offset]);        if (offset % 4 == 3) { printf(" "); }    }    printf("\n");}void hls_start(unsigned int* v_hls){    // Clear Interrupt    // Enable interrupt    //unsigned int ler_data = dma_get(v_hls, HLS_LIE_REGISTER);    //dma_set(v_hls, HLS_LIE_REGISTER, ler_data | 1);    // Enable Global Interrupt    //unsigned int gie_data = dma_get(v_hls, HLS_GIE_REGISTER);    //dma_set(v_hls, HLS_GIE_REGISTER, 1);    //    unsigned int data = dma_get(v_hls, HLS_CONTROL_REGISTER) & 0x80;    dma_set(v_hls, HLS_CONTROL_REGISTER, data | 0x01);}int main() {    int dh = open("/dev/mem", O_RDWR | O_SYNC); // Open /dev/mem which represents the whole physical memory    unsigned int* virtual_address = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, 0x40400000); // Memory map AXI Lite register block    float * virtual_source_address  = mmap(NULL, 69631, PROT_READ | PROT_WRITE, MAP_SHARED, dh, 0x0e000000); // Memory map source address   float * virtual_destination_address = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, 0x0f000000); // Memory map destination address    unsigned int* virtual_hls_address = mmap(NULL, 65535, PROT_READ | PROT_WRITE, MAP_SHARED, dh, 0x43c00000); // Memory map AXI Lite control of HLS accel.    //virtual_source_address[0]= 0x11223344; // Write random stuff to source block    //memset(virtual_destination_address, 0, 32); // Clear destination block    float a[SIZE][SIZE], b[SIZE];    float out[SIZE];    float ref_out[SIZE];    int i, j, k;    for(i = 0; i < SIZE; i++) {        for(j = 0; j < SIZE; j++) {            a[i][j] = ((float)rand())/RAND_MAX;             virtual_source_address[i * SIZE + j] = a[i][j];        }        b[i] = ((float)rand())/RAND_MAX;        virtual_source_address[i + SIZE * SIZE] =  b[i];    }    for(i = 0; i < SIZE; i++) {        float sum = 0;        for(k = 0; k < SIZE; k++)            sum += a[i][k] * b[k];        ref_out[i] = sum;    }    //printf("Copy matrix A to DDR\n"); memcpy(virtual_source_address, a, sizeof(float)*32*32);    //printf("Copy matrix B to DDR\n"); memcpy(virtual_source_address + 32*32, b, sizeof(float)*32*32);    //printf("Initializing output at DDR\n"); memset(virtual_destination_address, 0, sizeof(float)*32*32);    printf("Matrix A at source memory block:      "); memdump(virtual_source_address, sizeof(float)*SIZE*SIZE);    printf("Vector B at source memory block:      "); memdump(virtual_source_address + SIZE*SIZE, sizeof(float)*SIZE);    printf("Destination Memset: "); memset(virtual_destination_address, 3, sizeof(float)*SIZE);    printf("Destination memory block: "); memdump(virtual_destination_address, sizeof(float)*SIZE);    printf("Starting HLS accelerator with all interrupts disabled...\n");    hls_start(virtual_hls_address);    hls_accel_status(virtual_hls_address);    printf("Resetting DMA\n");    dma_set(virtual_address, S2MM_CONTROL_REGISTER, 4);    dma_set(virtual_address, MM2S_CONTROL_REGISTER, 4);    dma_s2mm_status(virtual_address);    dma_mm2s_status(virtual_address);    printf("Halting DMA\n");    dma_set(virtual_address, S2MM_CONTROL_REGISTER, 0);    dma_set(virtual_address, MM2S_CONTROL_REGISTER, 0);    dma_s2mm_status(virtual_address);    dma_mm2s_status(virtual_address);    /***********************  MM2S ***********************/    // A    printf("Writing source address...\n");    dma_set(virtual_address, MM2S_START_ADDRESS, 0x0e000000); // Write source address    dma_mm2s_status(virtual_address);        printf("Starting MM2S channel with all interrupts masked...\n");    dma_set(virtual_address, MM2S_CONTROL_REGISTER, 0x0001);    dma_mm2s_status(virtual_address);    printf("Writing MM2S transfer length...\n");    dma_set(virtual_address, MM2S_LENGTH, sizeof(float)*SIZE*SIZE);    dma_mm2s_status(virtual_address);    hls_accel_status(virtual_hls_address);    printf("Waiting for MM2S synchronization...\n");    dma_mm2s_sync(virtual_address, virtual_hls_address);    // B    printf("Writing source address...\n");    dma_set(virtual_address, MM2S_START_ADDRESS, 0x0e001000); // Write source address    dma_mm2s_status(virtual_address);        printf("Starting MM2S channel with all interrupts masked...\n");    dma_set(virtual_address, MM2S_CONTROL_REGISTER, 0x0001);    dma_mm2s_status(virtual_address);    printf("Writing MM2S transfer length...\n");    dma_set(virtual_address, MM2S_LENGTH, sizeof(float)*SIZE);    dma_mm2s_status(virtual_address);    hls_accel_status(virtual_hls_address);    printf("Waiting for MM2S synchronization...\n");    dma_mm2s_sync(virtual_address, virtual_hls_address);    /***********************  S2MM ***********************/    printf("Writing destination address\n");    dma_set(virtual_address, S2MM_DESTINATION_ADDRESS, 0x0f000000); // Write destination address    dma_s2mm_status(virtual_address);    printf("Starting S2MM channel with all interrupts disabled...\n");    dma_set(virtual_address, S2MM_CONTROL_REGISTER, 0x0001);    dma_s2mm_status(virtual_address);    printf("Writing S2MM transfer length...\n");    dma_set(virtual_address, S2MM_LENGTH, sizeof(float)*SIZE);    dma_s2mm_status(virtual_address);    hls_accel_status(virtual_hls_address);    printf("Waiting for MM2S sychronization...\n"); // Notice this is MM2S!!!    dma_mm2s_sync(virtual_address, virtual_hls_address); // If this locks up make sure all memory ranges are assigned under Address Editor!    /***********************  Sync with MM2S and S2MM together  ***********************/    //printf("Waiting for HLS sychronization...\n");    //hls_accel_sync(virtual_address, virtual_hls_address);     printf("Waiting for DMA - MM2S & S2MM synchronization...\n");    dma_sync(virtual_address, virtual_hls_address);    dma_s2mm_status(virtual_address);    dma_mm2s_status(virtual_address);    hls_accel_status(virtual_hls_address);    printf("Destination memory block: "); memdump(virtual_destination_address, sizeof(float)*SIZE);    //printf("Copy output from DDR\n"); memcpy(out, virtual_destination_address, sizeof(float)*32*32);    // sanity check    int err = 0;    for(i = 0; i < SIZE; i++) {            if(virtual_destination_address[i] != ref_out[i])            {err++;                printf("At address %d, ref output is %f, while HLS's result is %f", i, ref_out[i], virtual_destination_address[i]);            }    }    if (err == 0)        printf("Matrixes identical ... Test successful!\r\n");    else        printf("Test failed!\r\n");    // stop HLS    //dma_set(virtual_hls_address, HLS_CONTROL_REGISTER, tmp | 0x00);}