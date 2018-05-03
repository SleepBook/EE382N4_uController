//this is an naive implementation of page rank 
//in pure SW
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

#define DEBUG

int PageRank_Naive(float** mat, float* vec, int iter, int size, long* time)
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
                temp += mat[j][k] * vec[k];
            }
            buf[j] = temp;
        }
        loc = buf;
        buf = vec;
        vec = loc;
    }
    gettimeofday(&end, NULL);
    free(buf);
    *time = end.tv_sec*1000000 + end.tv_usec - start.tv_sec*1000000 - start.tv_usec;
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

    /*
    fin = fopen(argv[2], "rb");
    if(!fin){
        printf("open file error\n");
        for(i=0;i<size;i++){
            free(mat[i]);
        }
        free(mat);
        return -1;
    }
    
    fread(&i, 4, 1, fin);
    if(i != size){
        printf("vector size doesn't match matrix\n");
        for(i=0;i<size;i++){
            free(mat[i]);
        }
        free(mat);
        fclose(fin);
        return -1;
    }
    */
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
#endif

    printf("start computing for %d interations\n",iter);

    long duration;
    int err;
    err = PageRank_Naive(mat, vec, iter, size, &duration);
    printf("Computing done, use time %ld us\n", duration);

    for(i=0;i<size;i++){
        free(mat[i]);
    }
    free(mat);
    free(vec);
    return 0;
}








