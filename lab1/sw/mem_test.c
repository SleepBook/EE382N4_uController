#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

#define PORT_A_ADDR 0x40000000
#define PORT_B_ADDR 0x40002000
#define ADDR_LSFR_DATA 0x43C00000
#define ADDR_LSFR_CTRL 0x43C00004
#define DATA_LSFR_DATA 0x43C00000
#define DATA_LSFR_CTRL 0x43C00004
#define TEST_LENGTH 1024

typedef struct cell{
    unsigned long port;
    unsigned long data;
    unsigned long inter;
} cell;

void main()
{
    //use 2 bits to represent r/w port
    //0 for port A, 1 for port B
    int port_flag;

    FILE* log;
    FILE* diag;
    log = fopen("log.txt","w");
    diag = fopen("report.txt", "w");
    int count;

    cell status[TEST_LENGTH];

    //Mem Maping
    int fd = open("/dev/mem", 0_RDWR|0_SYNC, S_IRUSR);
    if(fd == -1){
        printf("unable to open /dev/mem");
        return -1;
    }

    

    





    

