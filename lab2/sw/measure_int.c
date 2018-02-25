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

struct timeval tv1, tv2;


int assertInt()
{
    volatile unsigned int *int_control;
    int fd = open("/dev/mem", O_RDWR|O_SYNC);
    //int fd = open("/dev/mem", O_RDWR|O_SYNC, S_IRUSR); 
    if(fd == -1){
        printf("unable to open /dev/mem");
        exit(-1);
    }

    int_control = (unsigned int*)mmap(NULL, MAP_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, INT_TRIGGER & ~MAP_MASK);
    *int_control  = 1;

    close(fd);
    munmap(NULL, MAP_SIZE);
    return 0;
}


void sighandler(int signo)
{
    if (signo==SIGIO)
        gettimeofday(&tv2);
    printf("APP:interrupt: Interrupt captured by SIGIO\n");
    return;
}


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
     * let the currecnt process to receive the SIGIO signal 
     * associated with this file
     */
    fc = fcntl(fd, F_SETOWN, getpid());
    
    if (fc == -1) {
    	perror("SETOWN failed\n");
    	rc = fd;
    	exit (-1);
    } 
      
    /*
     * Change the file status descriptor, which will
     * triger the fasync func in kernel, which call the 
     * fasync_helper to do something on the signal queue
     *
     * And in this kernel part, this action basically 
     * ensures that a SIGIO signal is dispatched when 
     * the kernel calls the fill_fasync func, which should 
     * appear in the interrupt handler
     */
    fc= fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_ASYNC);

    if (fc == -1) {
    	perror("SETFL failed\n");
    	rc = fd;
    	exit (-1);
    }   


    /*==============================================
     * Testing INterval Part
     */

    int status;
    int interval;
    gettimeofday(&tv1);
    status = assertInt();
    sleep(86400);
    //INterval is in usec
    printf("process wake up, interrupt handled correctly\n");
    interval = (int)((tv2.tv_sec - tv1.tv_sec)*1000 - (tv2.tv_usec - tv1.tv_usec));
    printf("The Interrupt took %d usecs to handle\n", interval);
    return 0;
}
    

