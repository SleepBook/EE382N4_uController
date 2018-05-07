#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include "point17.hpp"
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>

#define MAX_WIDTH  512

Point17 m[MAX_WIDTH][MAX_WIDTH];
Point17 v[MAX_WIDTH];
Point17 r[MAX_WIDTH];

void float2hex(float f, char * buf)
{
    char * pchar = (char *)&f;
    char val;
    val = pchar[3] >> 4;
    if(0<= val && val <= 9)
        buf[0] = val + '0';
    else
        buf[0] = val + 'A' - 10;
    val = pchar[3] & 0xF;
    if(0<= val && val <= 9)
        buf[1] = val + '0';
    else
        buf[1] = val + 'A' - 10;
    val = pchar[2] >> 4;
    if(0<= val && val <= 9)
        buf[2] = val + '0';
    else
        buf[2] = val + 'A' - 10;
    val = pchar[2] & 0xF;
    if(0<= val && val <= 9)
        buf[3] = val + '0';
    else
        buf[3] = val + 'A' - 10;
    val = pchar[1] >> 4;
    if(0<= val && val <= 9)
        buf[4] = val + '0';
    else
        buf[4] = val + 'A' - 10;
    val = pchar[1] & 0xF;
    if(0<= val && val <= 9)
        buf[5] = val + '0';
    else
        buf[5] = val + 'A' - 10;
    val = pchar[0] >> 4;
    if(0<= val && val <= 9)
        buf[6] = val + '0';
    else
        buf[6] = val + 'A' - 10;
    val = pchar[0] & 0xF;
    if(0<= val && val <= 9)
        buf[7] = val + '0';
    else
        buf[7] = val + 'A' - 10;
    buf[8] = '\0';
}

int main(int argc, char * argv[])
{
    int iter = 1;
    int i, j, idx;
    double pri;
    struct timeval origin, tostart, donecomputing, end;
    gettimeofday(&origin, NULL);

    if(3 > argc)
    {
        printf("Usage: %s <matrix_fix.binary> <result.binary> [#iter]\n", argv[0]);
        return -1;
    }
    else if (3 < argc)
        iter = atoi(argv[3]);

    FILE * fin = fopen(argv[1], "rb");
    if(NULL == fin)
    {
        printf("Error: unable to read %s \n", argv[1]);
        return -2;
    }
    unsigned int aint;
    fread((char*)(&aint), 4, 1, fin);
    const int num_col = aint;
    //printf("Expected Matrix Size %dx%d\n", num_col, num_col);
    for(i = 0; i < num_col; ++i)
        for(j = 0; j < num_col; ++j)
        {
            fread((char*)(&aint), 4, 1, fin);
            m[i][j] = aint;
            if(feof(fin))
            {
                printf(
                        "Error: %d elements is less than expected (%d elements)\n",
                        i*num_col+j,
                        num_col*num_col
                      );
                fclose(fin);
                return -3;
            }
        }
    fclose(fin);

    //for(i = 0; i < num_col; i+=NUM_NODES)
    //    for(j = 0; j < num_col; ++j)
    //    {
    //        std::cout << "Column " << j << " :\n";
    //        for(idx = 0; idx < NUM_NODES; ++idx)
    //        {
    //            std::cout << i + idx << '\t' << m[i+idx][j] << std::endl;
    //        }
    //    }

    /* check matrix submatrix by submatrix */
    //for(i = 0; i < num_col; i+=6)
    //{
    //    for(j = 0; j < num_col; j+=6)
    //    {
    //        printf("\nSubmatrix[%d][%d]:\n", i/6, j/6);
    //        for(idx = 0; idx < 36; ++idx)
    //        {
    //            char buf[9];
    //            //printf("m[%2d][%2d]=%f\n", i+idx, j, m[i+idx][j]);
    //            //printf("%02X%02X%02X%02X\n", afloat[0], afloat[1], afloat[2], afloat[3]);
    //            float2hex(m[i+idx/6][j+idx%6], buf);
    //            printf("%s", buf);
    //            if(5 == idx%6)
    //                printf("\n");
    //            else
    //                printf(" ");
    //        }
    //    }
    //}

    Point17 init_rank;
    init_rank = 1.0 / num_col;
    Point17 * pv;
    Point17 * pr;
    for(idx = 0, pv = v; idx < num_col; ++idx)
    {
        pv[idx] = init_rank;
    }

    gettimeofday(&tostart, NULL);
    // Computation starts from here
    int iter_cnt;
    for(iter_cnt = 0; iter_cnt < iter; ++iter_cnt)
    {
        //printf("\nIteration %d \n", iter_cnt);
        if(iter_cnt % 2)
        {
            pv = r;
            pr = v;
        }
        else
        {
            pv = v;
            pr = r;
        }
        for(i = 0; i < num_col; ++i)
        {
            //std::cout << "Row " << i << " :\n";
            for(j = 0, pri = 0; j < num_col; ++j)
            {
                //std::cout << "\n\t \t";
                //std::cout << m[i][j];
                //std::cout << "\n\tX\t";
                //std::cout << pv[j];
                //std::cout << "\n\t+\t";
                pr[i] = pri;
                //std::cout << pr[i];
                //std::cout << "\n\t=\t";
                pri += m[i][j].todouble() * pv[j].todouble();
                pr[i] = pri;
                //std::cout << pr[i];
                //std::cout << std::endl;
            }
            //std::cout << std::endl;
        }
        /* check results */
        //for(idx = 0; idx < num_col; ++idx)
        //{
        //    char buf[9];
        //    float2hex(pr[idx], buf);
        //    if(0 == idx%6)
        //        printf("%3d~%3d: ", idx, idx+5);
        //    //printf("%s", buf);
        //    printf("%.5f", pr[idx]);
        //    if(5 == idx%6)
        //        printf("\n");
        //    else
        //        printf(" ");
        //}
    }
    gettimeofday(&donecomputing, NULL);
//
//    /* print in floating point format to check */
//    printf("\nAfter %d iterations, the ranks are:\n", iter);
//    if(iter % 2)
//    {
//        for(idx = 0; idx < num_col; ++idx)
//            printf("%.5f ", r[idx]);
//    }
//    else
//    {
//        for(idx = 0; idx < num_col; ++idx)
//            printf("%.5f ", v[idx]);
//    }
//    printf("\n");
//
//    FILE * fout = fopen(argv[2], "wb");
//    if(NULL == fout)
//    {
//        printf("Error: unable to open %s\n", argv[3]);
//        return -7;
//    }
//    fwrite((void*)(&num_col), sizeof(num_col), 1, fout);
//    if(iter % 2)
//        fwrite((void*)(r), sizeof(r[0]), num_col, fout);
//    else
//        fwrite((void*)(v), sizeof(v[0]), num_col, fout);
//    fclose(fout);

    std::ofstream fout(argv[2], std::ios::binary | std::ios::out);

    fout.write((char*)&num_col, sizeof(num_col));

    if(iter % 2)
        pr = r;
    else
        pr = v;
    for(i = 0; i < num_col; ++i)
    {
        fout << pr[i];
        //std::cout << pr[i];
    }

    fout.close();

    gettimeofday(&end, NULL);

    long compute_time = donecomputing.tv_sec*1000000 + donecomputing.tv_usec - tostart.tv_sec*1000000 - tostart.tv_usec;
    long total_time = end.tv_sec*1000000 + end.tv_usec - origin.tv_sec*1000000 - origin.tv_usec;

    printf("Computation: %ld us\n", compute_time);
    printf("Total Exec : %ld us\n", total_time);

    return 0;
}
