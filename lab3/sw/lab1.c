/*
 * EE382N.4 Lab1 Mem Chcek
 * WEnqi Yin
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <assert.h>

#define PORT_A_ADDR 0x40000000
#define PORT_B_ADDR 0x40002000

#define INTERV_MASK 15
#define TEST_LENGTH 1024

typedef struct cell{
    unsigned data;
    unsigned inter;
} cell;

extern int pm(unsigned int paddr, unsigned int uval);
extern int dm(unsigned int pddr, unsigned int *ubuf);
extern unsigned int random10();
extern unsigned int random32();


int main(int argc, char *argv[])
{
    bool wp = (argc > 1)? (('b' == argv[1][0] || 'B' == argv[1][0])?1:0):0;
    bool rp = (argc > 2)? (('b' == argv[2][0] || 'B' == argv[2][0])?1:0):0;
    bool fail = (argc > 3)?(('f' == argv[3][0] || 'F' == argv[3][0])?1:0):0;

    int count = 0;
    int error_flag = 0;
    cell status[TEST_LENGTH] = {{0}};
    unsigned int mem_offset;
    unsigned int data;
    int p_addr;

    /* Main loop for Mem Test
     */
    while(1)
    {

        /* Test once */
        for(count = 0, error_flag = 0; count < TEST_LENGTH + INTERV_MASK + 1; ++count)
        {
            printf("\n==== Iter %4d ====\n", count);
            /* write part */
            if(count)
                mem_offset = random10();
            else
                mem_offset = 0;  // write the first location in memory in the first interation

            data = random32();

            if(fail)
            {
                if(wp)
                    p_addr = PORT_B_ADDR+(mem_offset&~0x3);
                else
                    p_addr = PORT_A_ADDR+(mem_offset&~0x3);
            }
            else
            {
                if(wp)
                    p_addr = PORT_B_ADDR+(mem_offset<<2);
                else
                    p_addr = PORT_A_ADDR+(mem_offset<<2);
            }
            assert(0 == pm(p_addr, data));

            status[mem_offset].data = data;
            status[mem_offset].inter = random32() & INTERV_MASK;
            if(1 > status[mem_offset].inter) status[mem_offset].inter = 7;

            printf("Write %8x to %8x, schedule to read it back at Iter %4d\n",
                    status[mem_offset].data,
                    p_addr,
                    count + status[mem_offset].inter - 1
                  );

            /* readback part */
            for(mem_offset = 0; mem_offset < TEST_LENGTH;++ mem_offset)
            {
                if(1 == status[mem_offset].inter)  // time to read back
                {
                    if(fail)
                    {
                        if(rp)
                            p_addr = PORT_B_ADDR+(mem_offset&~0x3);
                        else
                            p_addr = PORT_A_ADDR+(mem_offset&~0x3);
                    }
                    else
                    {
                        if(rp)
                            p_addr = PORT_B_ADDR+(mem_offset<<2);
                        else
                            p_addr = PORT_A_ADDR+(mem_offset<<2);
                    }
                    assert(0 == dm(p_addr, &data));
                    printf("Read %8x back from %8x, ", data, p_addr);

                    if(status[mem_offset].data != data)
                    {
                        error_flag = 1;
                        printf(" but should be %8x\n", status[mem_offset].data);
                    }
                    else
                        printf("correct\n");
                }

                if(0 < status[mem_offset].inter)
                    status[mem_offset].inter--;
            }
        }

        if(error_flag)
            printf("When fail = %d \nMEM Test failed :( \n", fail);
        else
            printf("MEM Test passed :) \n");

        /* delay and cleanup and setup for next test */
        //sleep(random32() % 10);
        sleep(1);

        for(mem_offset = 0; mem_offset < TEST_LENGTH; ++mem_offset)
            status[mem_offset].inter = 0;

        rp = random32() % 2;
        wp = random32() % 2;
        fail = random32() % 2;
    }

    return 0;
}

