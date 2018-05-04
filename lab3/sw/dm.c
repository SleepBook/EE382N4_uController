/*
 *  dm.c
 *
 *  author: Mark McDermott 
 *  Created: Feb 12, 2012
 *
 *  Simple utility to allow the use of the /dev/mem device to display memory
 *  and write memory addresses on the i.MX21.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */
 
#include "stdio.h"
#include "stdlib.h"
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <assert.h>
#include <unistd.h>

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

int dm(unsigned int paddr, unsigned int * ubuf) {

	int fd = open("/dev/mem", O_RDWR|O_SYNC, S_IRUSR);
	unsigned int *regs, *address ;
	
	unsigned int offset = paddr & MAP_MASK;

	if(fd == -1)
	{
		printf("Unable to open /dev/mem.  Ensure it exists (major=1, minor=1)\n");
		return -1;
	}	
    
    regs = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, paddr & ~MAP_MASK);	
    
	
	//printf("0x%.4x" , (paddr));

    address = regs + (offset>>2);    	
	
	//printf(" = 0x%.8x\n", *address);		// display register value
	
    *ubuf = *address;

    munmap(regs, MAP_SIZE);

	int temp = close(fd);
	if(temp == -1)
	{
		printf("Unable to close /dev/ram1.  Ensure it exists (major=1, minor=1)\n");
		return -1;
	}	

	//munmap(NULL, MAP_SIZE);
	
	return 0;
}

//int main(int argc, char * argv[])
//{
//    unsigned int addr = 0x43C00000;
//    unsigned int data;
//
//    while(1)
//    {
//        if(1 < argc)
//            addr = strtoul(argv[1], 0, 0);
//
//        assert(0 == dm(addr, &data));
//        printf("0x%08x=0x%08x\n", addr, data);
//    }
//
//    return 0;
//}
