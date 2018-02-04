/*
 * EE382N.4 Lab1 Mem Chcek
 * WEnqi Yin
 *
 * haven't add zero address test
 * led stuff omitted for now
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

//IO is lined to LED here, the low 8 bits are map to leds
#define IO_ADDR 0x41200008
#define PORT_A_ADDR 0x40000000
#define PORT_B_ADDR 0x40002000
#define ADDR_LSFR 0x43C00000
#define DATA_LSFR 0x43C00000
#define LSFR_CTRL_OFFSET 4

#define INTERV_MASK 0xf;
#define TEST_LENGTH 1024

typedef struct cell{
    unsigned long data;
    unsigned long inter;
} cell;

void main()
{
    /*
     * Least Two bits of Flag to represent R/W port
     * 0 for port A, 1 for port B
     */
    int port_flag = 0;

    FILE* log, diag;
    log = fopen("log.txt","w");
    diag = fopen("report.txt", "w");

    int count = 0;
    cell status[TEST_LENGTH];

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
    
    d_lsfr_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, DATA_LSFR & ~MAP_MASK);
    a_lsfr_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, ADDR_LSFR & ~MAP_MASK);
    d_lsfr_ctrl = d_lsfr_base + ((((DATA_LSFR + LSFR_CTRL_OFFSET))&MAP_MASK) >> 2);
    a_lsfr_ctrl = a_lsfr_base + ((((ADDR_LSFR + ADDR_CTRL_OFFSET))&MAP_MASK) >> 2);

    porta_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, PORT_A_ADDR & ~MAP_MASK);
    portb_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, PORT_B_ADDR & ~MAP_MASK);



    /* Main loop for Mem Test
     */
    int error_flag = 0;
    while(1){
        unsigned int data;
        unsigned int mem_offset;
        unsigned int interval;
        unsigned int temp, i;
        unsigned int addr;
        fprintf(log, "================================\n");
        fprintf(log, "Cycle Count %d\n", count);

        if(count == TEST_LENGTH + INTERV_MASK - 1) break;
        else if(count < TEST_LENGTH - 1){
            //Refresh HW LSFR to get new data
            *a_lsfr_ctrl = 0;
            *a_lsfr_ctrl = 1;
            *d_lsfr_ctrl = 0;
            *d_lsfr_ctrl = 1;

            data = *d_lsfr_base;
            mem_offset = *a_lsfr_base;
            interval = data & INTERV_MASK;

            //create record
            status[mem_offset].data = data;
            status[mem_offset].inter = interval;

            //writing phase
            if((port_flag >> 1) & 0x1){
                addr = portb_base + ((((PORT_B_ADDR) + mem_offset)&MAP_MASK) >> 2);
            }
            else{
                addr = porta_base + ((((PORT_A_ADDR) + mem_offset)&MAP_MASK) >> 2);
            }
            *addr = data;
            fprintf(log, "Writing %u to mem offset %u\n", data, mem_offset);
        }

        //readback & check phase
        for(i=1;i<TEST_LENGTH;i++){
            if(status[i].inter == 0) continue;
            else if(status[i].inter == 1){
                if(port_flag & 0x1){
                    addr = portb_base + ((((PORT_B_ADDR) + i)&MAP_MASK) >> 2);
                }
                else{
                    addr = porta_base + ((((PORT_A_ADDR) + i)&MAP_MASK) >> 2);
                }
                data = *addr;
                fprintf(log, "Readback data from offset %u, the value is %u\n", i, data);
                if(data != status[i].data){
                    error_flag = 1;
                    /*
                     * And you could do some fancy LED stuff
                     */
                    fprintf(diag, "Defect Detected at MEM_OFFSET %u\n",i);
                    fprintf(log, "Defect Detected at MEM_OFFSET %u\n",i);
                }
            }
            status[i].inter--;
        }
        count++;
    }

    if(!error_flag){
        fprintf("Mem Test PASSED\n");
    }

    close(log);
    close(diag);
    close(fd);
    munmap(NULL, MAP_SIZE);
    return 0;
}

