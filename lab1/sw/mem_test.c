/*
 * EE382N.4 Lab1 Mem Chcek
 * WEnqi Yin
 *
 * haven't add zero address test
 * led stuff omitted for now
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

//IO is lined to LED here, the low 8 bits are map to leds
#define IO_ADDR 0x41200000 
#define PORT_A_ADDR 0x40000000
#define PORT_B_ADDR 0x40001000
#define ADDR_LSFR 0x43C00000
#define DATA_LSFR 0x43C01000
#define LSFR_CTRL_OFFSET 8
#define LED_OFFSET 8

#define INTERV_MASK 15
#define LED_MASK 0xff
#define TEST_LENGTH 1024

#define DEBUG 
//#define PART1
typedef struct cell{
    unsigned data;
    unsigned inter;
#ifdef DEBUG
    volatile unsigned int *v_addr;
#endif
} cell;

int main(int argc, char *argv[])
{
    bool wp = (argc > 1)? (('b' == argv[1][0] || 'B' == argv[1][0])?1:0):0;
    bool rp = (argc > 2)? (('b' == argv[2][0] || 'B' == argv[2][0])?1:0):0;
    bool fail = (argc > 3)?(('f' == argv[3][0] || 'F' == argv[3][0])?1:0):0;

    FILE* log, *diag;
    log = fopen("log.txt","w");
    diag = fopen("report.txt", "w");

    int count = 0;
    int i,j;
    cell status[TEST_LENGTH];
    for(i=0;i<TEST_LENGTH;i++){
        status[i].data = 0;
        status[i].inter = 0;
    }


    /*
     * Open Phy Mem
     */
    int fd = open("/dev/mem", O_RDWR|O_SYNC);
    if(fd == -1){
        printf("unable to open /dev/mem");
        return -1;
    }

    /*
     * DO memory Maping
     */

    volatile unsigned int *d_lsfr_base, *a_lsfr_base;
    volatile unsigned int *d_lsfr_ctrl, *a_lsfr_ctrl;
    volatile unsigned int *porta_base, *portb_base;
    volatile unsigned int *gpio_base, *led_base;

    d_lsfr_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, DATA_LSFR & ~MAP_MASK);
    a_lsfr_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, ADDR_LSFR & ~MAP_MASK);
    d_lsfr_ctrl = d_lsfr_base + ((((DATA_LSFR + LSFR_CTRL_OFFSET))&MAP_MASK) >> 2);
    a_lsfr_ctrl = a_lsfr_base + ((((ADDR_LSFR + LSFR_CTRL_OFFSET))&MAP_MASK) >> 2);

    porta_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, PORT_A_ADDR & ~MAP_MASK);
    portb_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, PORT_B_ADDR & ~MAP_MASK); 
    gpio_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, IO_ADDR & ~MAP_MASK); 
    led_base = gpio_base + ((((IO_ADDR + LED_OFFSET))&MAP_MASK) >> 2);

    // initial status for led;

    /* Main loop for Mem Test
     */
    int error_flag = 0;
    while(1){
        unsigned int data;
        unsigned int mem_offset;
        unsigned int interval;
        unsigned int temp, i;
        volatile unsigned int *addr;

        unsigned int p_addr, p_addr2;
        fprintf(log, "================================\n");
        fprintf(log, "Cycle Count %d\n", count);

        if(count == TEST_LENGTH){
            for(j=0;j<INTERV_MASK;j++){
                    for(i=0;i<TEST_LENGTH;i++){ //checking starts from 0
                        if(status[i].inter == 0) continue;
                        else if(status[i].inter == 1){
                            if(rp){
                                addr = portb_base + ((((PORT_B_ADDR) + i*4)&MAP_MASK) >> 2);
                            }
                            else{
                                addr = porta_base + ((((PORT_A_ADDR) + i*4)&MAP_MASK) >> 2);
                            }
                            data = *addr;
                            fprintf(log, "Readback data from offset %u, the value is %u\n", i, data);
                            if(data != status[i].data){
#ifdef DEBUG
                                printf("at address %u:\n", i);
                                printf("old value is %u, readin value is %u\n", status[i].data, data);
                                printf("the write in addr is %p, the readout addr is %p\n", (void*)status[i].v_addr, (void*)addr);
#endif
                                error_flag = 1;
                    
                                *led_base = 0;

                                fprintf(diag, "Defect Detected at MEM_OFFSET %u\n",i);
                                fprintf(log, "Defect Detected at MEM_OFFSET %u\n",i);
                            }
                        }
                        status[i].inter--;
                    }
            }
            break;
        }

        else if(count == 0){
            //generate the data for address 0;
            *d_lsfr_ctrl = 0;
            *d_lsfr_ctrl = 1;
        
            data = *d_lsfr_base;
            interval = data & INTERV_MASK;
            if(!interval) interval = 7;
            status[0].data = data;
            status[0].inter = interval;
#ifdef PART1
            status[0].inter = 1;
#endif

            if(wp){
                addr = portb_base + (((PORT_B_ADDR) &MAP_MASK) >> 2);
            }
            else{
                addr = porta_base + (((PORT_A_ADDR) &MAP_MASK) >> 2);
            }
            *addr = data;
            fprintf(log, "Writing %u to mem offset %u\n", data, 0);
        }

        else if(count < TEST_LENGTH){
            //Refresh HW LSFR to get new data
            *a_lsfr_ctrl = 0;
            *a_lsfr_ctrl = 1;
            *d_lsfr_ctrl = 0;
            *d_lsfr_ctrl = 1;

            data = *d_lsfr_base;
#ifdef DEBUG
            //data = 4189497481;
            //data = count;
#endif
            mem_offset = *a_lsfr_base;
            interval = data & INTERV_MASK;
            if(!interval) interval = 7;
#ifdef PART1
            interval = 1;
#endif
           
            //create record
            status[mem_offset].data = data;
            status[mem_offset].inter = interval;

            //writing phase
            if(fail){
                if(wp){
                    addr = portb_base + ((((PORT_B_ADDR) + mem_offset)&MAP_MASK) >> 2);
                }
                else{
                    addr = porta_base + ((((PORT_A_ADDR) + mem_offset)&MAP_MASK) >> 2);
                }
            }
            else{
                if(wp){
                    addr = portb_base + ((((PORT_B_ADDR) + mem_offset*4)&MAP_MASK) >> 2);
                }
                else{
                    addr = porta_base + ((((PORT_A_ADDR) + mem_offset*4)&MAP_MASK) >> 2);
                }
            }
#ifdef DEBUG
            status[mem_offset].v_addr = addr;
#endif
            *addr = data;
            //fprintf(log, "Writing %u to mem offset %p\n", data, addr);
            if(wp){
                fprintf(log, "Writing to Port B\n");
                p_addr = mem_offset + PORT_B_ADDR;
            }
            else{
                fprintf(log, "Writing to Port A\n");
                p_addr = mem_offset + PORT_A_ADDR;
            }
            fprintf(log, "Writing %u to mem offset 0x%.8x\n", data, p_addr);
        }

        //readback & check phase
        for(i=0;i<TEST_LENGTH;i++){ //checking starts from 0
            if(status[i].inter == 0) continue;
            else if(status[i].inter == 1){
                if(fail){
                    if(rp){
                        addr = portb_base + ((((PORT_B_ADDR) + i)&MAP_MASK) >> 2);
                    }
                    else{
                        addr = porta_base + ((((PORT_A_ADDR) + i)&MAP_MASK) >> 2);
                    }
                }
                else{
                    if(rp){
                        addr = portb_base + ((((PORT_B_ADDR) + i*4)&MAP_MASK) >> 2);
                    }
                    else{
                        addr = porta_base + ((((PORT_A_ADDR) + i*4)&MAP_MASK) >> 2);
                    }
                }
                data = *addr;
                if(rp){
                    fprintf(log, "Reading to Port B\n");
                    p_addr = i + PORT_B_ADDR;
                }
                else{
                    fprintf(log, "Reading to Port A\n");
                    p_addr = i + PORT_A_ADDR;
                }
                fprintf(log, "Readback data from offset 0x%.8x, the value is %u\n", p_addr, data);
                //fprintf(log, "Readback data from offset %p, the value is %u\n", addr, data);
                if(data != status[i].data){
#ifdef DEBUG
                    printf("at address %u:\n", i);
                    printf("old value is %u, readin value is %u\n", status[i].data, data);
                    printf("the write in addr is %p, the readout addr is %p\n", (void*)status[i].v_addr, (void*)addr);
#endif
                    error_flag = 1;
                    
                    *led_base = 0;

                    fprintf(diag, "Defect Detected at MEM_OFFSET %u\n",i);
                    fprintf(log, "Defect Detected at MEM_OFFSET %u\n",i);
                }
            }
            status[i].inter--;
        }
        count++;
    }

    if(!error_flag){
        fprintf(diag, "Mem Test PASSED\n");
        *led_base = (*led_base + 1) & LED_MASK;
    }

    close(log);
    close(diag);
    close(fd);
    munmap(NULL, MAP_SIZE);
    return 0;
}

