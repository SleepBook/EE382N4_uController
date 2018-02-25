/* EE382N.4 Lab2
 *
 * User-Space Program for measuring interrupt handling process
 * the kernel module handler will set a signal SIGIO, which is 
 * supposed to be captured by user-program
 *
 * Wenqi Yin
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>  

#define PL_PERI_MAJOR 245
#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)     

#define INT_TRIGGER 0x40000000

int det_int=0;
int num_int =0;

void sighandler(int signo)
{
    if (signo==SIGIO)
        det_int++;
    printf("APP:interrupt: Interrupt captured by SIGIO\n");
    return;
}

char buffer[4096];

int main(int argc, char **argv)
{
    int count;
    struct sigaction action;
    int fd;
    int rc;
    int fc;

    /* 
     * bond callback when SIGIO come in
     */
    sigemptyset(&action.sa_mask);
    sigaddset(&action.sa_mask, SIGIO);
    action.sa_handler = sighandler;
    action.sa_flags = 0;
    sigaction(SIGIO, &action, NULL);
    
    fd = open("/dev/fpga_int", O_RDWR);
    if (fd == -1) {
    	perror("Unable to open /dev/fpga_int");
    	rc = fd;
    	exit (-1);
    }
    
    printf("APP: /dev/fpga_int opened successfully\n");    	

    /*
     * Not exactly sure what SETOWN here will do
     */
    fc = fcntl(fd, F_SETOWN, getpid());
    
    if (fc == -1) {
    	perror("SETOWN failed\n");
    	rc = fd;
    	exit (-1);
    } 
      
    /* will triger the fasync func in kernel, which call the 
     * fasync_helper to do something on the signal queue
     */
    fc= fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_ASYNC);

    if (fc == -1) {
    	perror("SETFL failed\n");
    	rc = fd;
    	exit (-1);
    }   

    
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
*
*   This while loop emulates a program running the main
*   loop i.e. sleep(). The main loop is interrupted when
*   the SIGIO signal is received.
*/
    volatile unsigned int *address ;                                            
    unsigned long target_addr = 0x40000000;          
    
    while(1) {
    
        /* this only returns if a signal arrives */
        sleep(86400); /* one day */
        if (!det_int)
            continue;
        num_int++;
        
        printf("mon_interrupt: Number of interrupts detected: %d\n", num_int);

        int fd = open("/dev/mem", O_RDWR|O_SYNC, S_IRUSR); 
        address = (unsigned int *)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED,
                                       fd, target_addr & ~MAP_MASK);
        printf("0x%.4x" , (target_addr));
        printf(" = 0x%.8x\n", *address);              // display register value  
	
	    int temp = close(fd);
	    if(temp == -1)
	    {
		    printf("Unable to close /dev/mem.  Ensure it exists (major=1, minor=1)\n");
		    return -1;
	    }	       
	     det_int=0;
    }
}
