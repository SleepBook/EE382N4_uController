/*
 * User application of the final project: Hardware PageRank Acceleration
 * Transform the adjacent list to the matrix A
 * transform the matrix to PL bram
 * set ready bit
 * suspend itself to wait for the interrupt
 *
 * Wenqi Yin 
 * Apr. 1st 2018
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


//HW nodes
#define BRAM_DEV_NODE "/dev/fpga_bram"
#define ACC_DEV_NODE "/dev/pr_acc"


//Algorithm related pars
#define ALPHA 0.8
typedef struct matA{
    int dim;
    float* data;
} matA;

//signal relate vars
static volatile sig_atomic_t sidio_processed;
static int sigio_count = 0;

//other MACROS
#define DEBUG

/* 
 * transform adjacency list to a internal matrix
 * suppose the list is stored on secondary storage
 */
matA* list2matrix(char* filename)
{
    FILE* in_f;
    int errno;
    int i, j;
    int temp;
    char ch;

    int dim;
    matA *matrix;
    
    in_f = open(filename, 'r');
    if(in_f == 0){
#ifdef DEBUG
        printf("error open file\n");
#endif
        exit(-1);
    }

    fscanf(in_f, "%d", &dim);
    if(dim <= 0){
#ifdef DEBUG
        printf("invalid dimension read\n");
#endif
        exit(-1);
    }

    matrix = (matA*)malloc(sizeof(matA));
    if(matrix == 0){
        printf("error allocation space\n");
        exit(-1);
    }
    matrix.data = (float*)malloc(sizeof(float)*dim*dim);
    if(matrix.ptr == 0){
        printf("error allocating space\n");
        exit(-1);
    }

    //TODO, need to specify the specific file format
    for(i=0;i<dim;i++){
        for(j=0;j<dim;j++){
            fscanf(in_f, "%d", &temp);
            matrix.data[j*dim + i] = temp;
        }
    }
    
    //matA readin down
    return matrix;
}

/*
 * transform matrix to internal bram 
 * another thing need to make sure is whether this 
 * operation is stalled or not
 */
int data_transfer(matA* matrix){
    FILE* fd;
    int dim;
    fd = open(BRAM_DEV_NODE, O_RDWR);
    if(fd == -1){
        perror("unbale to open %s\n", BRAM_DEV_NODE);
        exit(-1);
    }
    dim = matrix->dim;
    write(fd, &matrix->data, sizeof(float)*dim*dim);
    return 0;
}

/* collecting result from bram when computing done
 */
float* collect_res(matA* matrix)
{
    float* res;
    int dim = matrix->dim;
    res = (float*)malloc(sizeof(float)*dim);
    //TODO
    //collect result from the device
    
    return res;

}


/* setting up the accelerator and computing
 */

void sighandler(int sigio)
{
    sigio_count++;
    sigio_processed = 1;
    return;
}

float* run_acc(matA* matrix)
{
    int fd, fc;

    fd = open(ACC_DEV_NODE, 0_RDWR);
    if(fd == -1){
        perror("unable to open %s\n", ACC_DEV_NODE);
        exit(-1);
    }

    fc = fcntl(fd, F_SETOWN, getpid());
    if(fc == -1){
        perror("SETOWN failed\n");
        close(fd);
        exit(-1);
    }
    fc = fcntrl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_ASYNC);
    if(fc == -1){
        perror("SETFL failed\n");
        exit(-1);
    }

    sigio_processed = 0;
    (void)sigfillset(&signal_mask);
    (void)sigfillset(&signal_mask_most);
    (void)sigdelset(&signal_mask_most, SIGIO);
    (void)sigprocmask(SIG_SETMASK, &signal_mask, &signal_mask_old);

    int dim = matrix->dim;
    write(fd, &dim, 4);
    //acc starts to operate
    
    if(sigio_processed == 0){
        rc = sigsuspend(&signal_mask_most);
        assert(-1 == rc && sigio_processed);
    }

    //process wake up from here
    (void)sigprocmask(SIG_SETMASK, &signal_mask_old, NULL);
    return collect_res();

}

int main(int argc, char** argv)
{
    int errno;
    float* result;
    matA* matrix = list2matrix(argv[1]);
    errno = data_transfer(matrix);
    if(errno){
        printf("error happened when sending data to fpga");
        exit(-1);
    }
    result = run_acc(matrix);
    show_result(result);

    //clear up
    free(res);
    free(matrix->data);
    free(matrix);
    return 0;
}

    



    
    






        
