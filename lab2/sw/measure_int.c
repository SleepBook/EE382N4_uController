/* EE382N.4 Lab2
 *
 * User-Space Program for measuring interrupt handling process
 * the kernel module handler will set a signal SIGIO, which is 
 * supposed to be captured by user-program
 *
 * 
 * Wenqi Yin
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>  
#include <assert.h>

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1) 
#define NUM_MEASUREMENTS 10000

struct timeval tv1, tv2;
static volatile sig_atomic_t sigio_signal_processed;
static int sigio_signal_count = 0;

int cmpfunc (const void *a, const void *b) {
    return (*(int*)a - *(int*)b);
}

int assertInt(int fd)
{
    int input = 0;
    write(fd, &input, 4);
    input = 1;
    write(fd, &input, 4);
    return 0;
}


void sighandler(int signo)
{
    sigio_signal_count++;
    sigio_signal_processed = 1;
    if (signo==SIGIO)
        gettimeofday(&tv2);
    //printf("APP:interrupt: Interrupt captured by SIGIO\n");
    return;
}


int main(int argc, char **argv)
{
    int count = 1;  /* by default loop once */
    struct sigaction action;
    int fd;  /* device node */
    int rc;
    int fc;  /* current process */

    if(1 < argc)  /* loop count is specified */
        count = atoi(argv[1]);

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
    	/* rc = fd; */
    	exit (-1);
    }
    //printf("APP: /dev/fpga_int opened successfully\n");    	

    /*
     * let the currecnt process to receive the SIGIO signal 
     * associated with this file
     */
    fc = fcntl(fd, F_SETOWN, getpid());
    
    if (fc == -1) {
    	perror("SETOWN failed\n");
    	/* rc = fd; */
        close(fd);
    	exit (-1);
    } 
      
    /*
     * Change the file status descriptor, which will
     * triger the fasync func in kernel, which call the 
     * fasync_helper to do something on the signal queue
     *
     * And in this kernel part, this action basically 
     * ensures that a SIGIO signal is dispatched when 
     * the kernel calls the kill_fasync func, which should 
     * appear in the interrupt handler
     */
    fc= fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_ASYNC);

    if (fc == -1) {
    	perror("SETFL failed\n");
    	/* rc = fd; */
    	exit (-1);
    }   


    /*==============================================
     * Testing Interval Part
     * Update on Mar 18th 2018:
     *      replace the sleep() with new interface, which 
     *      guarantee sig miss won't happen and thus is
     *      deadlock-safe
     */

    int status;
    int interval;
    sigset_t signal_mask, signal_mask_old, signal_mask_most;

    //latency 
    int j, k, loopcnt;
    int sum = 0;
    double sum_sq_diff = 0, average = 0, std_dev = 0;
    int latency[NUM_MEASUREMENTS];
    
    //csv op
    FILE *fp;
    const char *filename = "measure_int.csv";
    fp = fopen(filename, "w+");
    fprintf(fp, "# irq, latency\n");

    for(loopcnt = 0; loopcnt < 300; loopcnt++)
    {

for(k = 0; k < NUM_MEASUREMENTS; k++) {
    //single round measuring
    sigio_signal_processed = 0;
    (void)sigfillset(&signal_mask);
    (void)sigfillset(&signal_mask_most);
    (void)sigdelset(&signal_mask_most, SIGIO);
    (void)sigprocmask(SIG_SETMASK, &signal_mask, &signal_mask_old);

    //status = assertInt(fd);
    int input = 0;

    //gettimeofday(&tv1);
    write(fd, &input, 4);
    gettimeofday(&tv1);
    input = 1;
    //printf("%d\n", input);
    write(fd, &input, 4);

    if(sigio_signal_processed == 0){
        rc = sigsuspend(&signal_mask_most);
        assert(-1 == rc && sigio_signal_processed);
    }
    (void)sigprocmask(SIG_SETMASK, &signal_mask_old, NULL);
    assert(sigio_signal_count == loopcnt * NUM_MEASUREMENTS + k + 1);
    
    //INterval is in usec
    //printf("process wake up, interrupt handled correctly\n");
    interval = (int)((tv2.tv_sec - tv1.tv_sec)*1000000 + (tv2.tv_usec - tv1.tv_usec));
    //printf("The Interrupt took %d usecs to handle\n", interval);
    latency[k] = interval;
    sum += latency[k];
    fprintf(fp, "%d,%d\n", k+1, latency[k]);
}   
    qsort(latency, NUM_MEASUREMENTS, sizeof(int), cmpfunc);
    average = (double)sum / (double)NUM_MEASUREMENTS;
    for(j = 0; j < NUM_MEASUREMENTS; j++) {
        sum_sq_diff += (latency[j] - average) * (latency[j] - average);
    }
    
    std_dev = sqrt((double)sum_sq_diff / (double)(NUM_MEASUREMENTS - 1));

    printf("Minimum Latency:    %d\n", latency[0]);
    printf("Maximum Latency:    %d\n", latency[NUM_MEASUREMENTS - 1]);
    printf("Average Latency:    %.6f\n", average);
    printf("Standard Deviation: %.6f\n", std_dev);
    printf("Number of samples:  %d\n", NUM_MEASUREMENTS);
    system("grep \"fpga_int\" /proc/interrupts");
    printf("\n");
    system("sleep 1");

    }

    fclose(fp);
    return 0;
}
    

