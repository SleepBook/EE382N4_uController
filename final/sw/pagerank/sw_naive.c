//this is an naive implementation of page rank 
//in pure SW
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

//#define DEBUG
int PageRank_Naive(float** mat, float** vec, int iter, int size, long* time)
{
    int i, j, k;
    float* buf, *loc;
    float temp = 0;
    struct timeval start, end;
    buf = (float*)malloc(sizeof(float)*size);
    if(!buf) return -1;

    gettimeofday(&start, NULL);
    for(i=0;i<iter;i++){
        for(j=0;j<size;j++){
            temp = 0;
            for(k=0;k<size;k++){
                temp += mat[j][k] * (*vec)[k];
            }
            buf[j] = temp;
        }
        loc = buf;
        buf = *vec;
        *vec = loc;
    }
    gettimeofday(&end, NULL);
    free(buf);
    *time = end.tv_sec*1000000 + end.tv_usec - start.tv_sec*1000000 - start.tv_usec;
}

long computeTime(struct timeval* start, struct timeval* end)
{
    long interval;
    interval = ((end->tv_sec - start->tv_sec) * 1000000 + end->tv_usec - start->tv_usec);
    return interval;
}

//read from some binary file of a matrix represent some graph
//first para is the matrix binary file, 
//second is the iteration
int main(int argc, char** argv)
{
    if(argc != 3){
        printf("Correct input tool matfile vecfile iter\n");
        return -1;
    }
    struct timeval start, end;

    gettimeofday(&start, NULL);
    int iter = atoi(argv[2]);
    FILE* fin = fopen(argv[1], "rb");
    if(!fin){
        printf("open file error\n");
        return -1;
    }

    int size;
    int i,j;
    float buf;
    float** mat;
    float* vec;

    fread(&size, 4, 1, fin);

    mat = (float**)malloc(sizeof(float*)*size);
    if(mat == 0) return -1;
    for(i=0;i<size;i++){
        mat[i] = (float*)malloc(sizeof(float)*size);
        if(mat[i] == 0){
            for(j=0;j<i;j++){
                free(mat[j]);
            }
            free(mat);
            return -1;
        }
    }

    for(i=0;i<size;i++){
        for(j=0;j<size;j++){
            fread(&mat[i][j], 4, 1, fin);
        }
    }

    fclose(fin);
#ifdef DEBUG
    printf("read in matrix done\n");
    for(i=0;i<size;i++){
        for(j=0;j<size;j++){
            printf("%f ", mat[i][j]);
        }
        printf("\n");
    }
#endif


    vec = (float*)malloc(sizeof(float)*size);
    if(!vec){
        for(i=0;i<size;i++){
            free(mat[i]);
        }
        free(mat);
        return -1;
    }

    for(i=0;i<size;i++){
        vec[i] = 1.0/size;
    }
#ifdef DEBUG
    printf("read vector done\n");
    for(i=0;i<size;i++){
        printf("%f ", vec[i]);
    }
    printf("\n");

    printf("start computing for %d interations\n",iter);
#endif

    long duration;
    int err;
    err = PageRank_Naive(mat, &vec, iter, size, &duration);
#ifdef DEBUG
    printf("Computing done, use time %ld us\n", duration);
    printf("the result vector is:\n");
    for(i=0;i<size;i++){
        printf("%f ", vec[i]);
    }
    printf("\n");
#endif

    for(i=0;i<size;i++){
        free(mat[i]);
    }
    free(mat);
    free(vec);
    gettimeofday(&end, NULL);
    long intv = computeTime(&start, &end); 
    printf("the total time is %ld\n", intv);
    printf("Computing done, use time %ld us\n", duration);
    return 0;
}








