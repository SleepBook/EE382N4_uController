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

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1) 
#define BRAM_ADDR 0x40000000
#define CNTL_ADDR 0x40001000

#define ALPHA 0.8

typedef struct matA{
    int dim;
    float* data;
} matA;

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


int main()
{

    



    
    






        
