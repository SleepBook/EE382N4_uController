#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

#define IO_ADDR 0x41200000

typedef struct cell{
    unsigned long addr;
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

    volatile unsigned int *virt_base, *addr;
    volatile unsigned int phy_addr, virt_addr;
    unsinged long offset;

    phy_addr = IO_ADDR;
    virt_base = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, IO_ADDR & ~MAP_MASK);

    //single address write test
    phy_addr = IO_ADDR;
    offset = (phy_addr & MAP_MASK) >> 2;
    virt_addr = virt_base + offset;

    unsigned int i;
    char input;
    for(i=0;i<16;i++){
        scanf("%c", &input);
        *virt_addr = i;
    }

    close(log);
    close(diag);
    close(fd);
    munmap(NULL, MAP_SIZE);
}



    

