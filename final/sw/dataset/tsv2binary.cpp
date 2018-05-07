#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstdlib>
#include <string>
#include "point17.hpp"

#define MAX_SIZE 512
#define SELF_CONSTANT 0.15
#define NUM_NODES 8

bool m[MAX_SIZE][MAX_SIZE] = {0};  // ajancency matrix
float t[MAX_SIZE][MAX_SIZE] = {0};  // transposed matrix for fp hw accel
float s[MAX_SIZE][MAX_SIZE] = {0};  // sparse matrix for sw
Point17 pt17[MAX_SIZE][MAX_SIZE];  // transposed matrix for fixed point accel

int max_size;

void eval_one_line(FILE * fin)
{
    char * pline = NULL;
    size_t n = 0;
    ssize_t nchar = 0;
    nchar = getline(&pline, &n, fin);
    if(0 < n && '%' != pline[0])  // not empty nor comment
    {
        int idx0, idx1;  // indexes to evaluate string char by char
        int sid, tid;  // source vertex id, target vertex id
        for(idx0 = 0, sid = -1; idx0 < nchar; ++idx0)
        {
            if('0' > pline[idx0] || pline[idx0] > '9')
            {
                pline[idx0] = '\0';  // make a substring
                sid = atoi(pline);
                break;
            }
        }
        for(idx1 = idx0 + 1, tid = -1; idx1 < nchar; ++idx1)
        {
            if('0' > pline[idx1] || pline[idx1] > '9')
            {
                pline[idx1] = '\0';  // make a substring
                tid = atoi((char*)(pline+idx0+1));
                break;
            }
        }
        //printf("%3d -> %3d\n", sid, tid);
        if(0 <= sid && sid < max_size && 0 <= tid && tid < max_size)
        {
            m[sid][tid] = 1;
        }
    }
    free(pline);
}

void transpose_one_row(int idx)
{
    int col, num_out_edge;

    for(num_out_edge = 0, col = 0; col < max_size; ++col)
    {
        if(m[idx][col])
            ++num_out_edge;
    }

    const float fixed = SELF_CONSTANT / max_size;
    const float share = num_out_edge ?
        ((1.0 - SELF_CONSTANT) / num_out_edge) : 0;
    const float makeup = num_out_edge ?
        0 : ((1.0 - SELF_CONSTANT) / max_size);

    for(col = 0; col < max_size; ++col)
    {
        if(m[idx][col])
            t[col][idx] = fixed + share;
        else
            t[col][idx] = fixed + makeup;
    }
    for(col = 0; col < max_size; ++col)
    {
        if(m[idx][col])
            s[col][idx] = share;
        else
            s[col][idx] = 0;
    }
}

void fillpt17()
{
    int i, j;
    for(i = 0; i < max_size; ++i)
        for(j = 0; j < max_size; ++j)
            pt17[i][j] = t[i][j];
}

int main(int argc, char * argv[])
{
    if(3 > argc)
    {
        printf("Usage: %s <input.tsv> <output base name> [max_size]\n", argv[0]);
        return -1;
    }
    else if(3 < argc)
    {
        max_size = atoi(argv[3]);
        if(max_size > MAX_SIZE)
            max_size = MAX_SIZE;
    }
    else
        max_size = MAX_SIZE;

    FILE * fin = fopen(argv[1], "r");
    if(NULL == fin)
    {
        printf("Error: unable to open %s\n", argv[1]);
        return -2;
    }

    while(!feof(fin))
    {
        eval_one_line(fin);
    }

    fclose(fin);

    int i, j;
    //for(j = 0; j < 10; ++j)
    //{
    //    for(i = 0; i < 10; ++i)
    //    {
    //        printf("%d ", m[i][j]);
    //    }
    //    printf("\n");
    //}

    int idx;
    for(idx = 0; idx < max_size; ++idx)
    {
        transpose_one_row(idx);
    }

    //for(j = 0; j < 10; ++j)
    //{
    //    for(i = 0; i < 10; ++i)
    //    {
    //        printf("%.4f ", t[i][j]);
    //    }
    //    printf("\n");
    //}

    fillpt17();

    //for(j = 0; j < max_size; ++j)
    //{
    //    std::cout << "Column " << j << " :\n";
    //    for(i = 0; i < max_size; ++i)
    //    {
    //        std::cout << i << '\t' << pt17[i][j] << std::endl;
    //    }
    //    std::cout << std::endl;
    //}

    std::string basename = argv[2];

    // writing binary file for sw
    std::ofstream fout_sw(basename + "_sw.binary", std::ios::out | std::ios::binary);
    fout_sw.write((char*)(&max_size), 4);

    for(i = 0; i < max_size; ++i)
        for(j = 0; j < max_size; ++j)
        {
            fout_sw.write((char*)(&s[i][j]), 4);
        }

    fout_sw.close();

    // writing binary file for fp hw accel
    std::ofstream fout_float(basename + "_float.binary", std::ios::out | std::ios::binary);
    fout_float.write((char*)(&max_size), 4);

    for(i = 0; i < max_size; ++i)
        for(j = 0; j < max_size; ++j)
        {
            fout_float.write((char*)(&t[i][j]), 4);
        }

    fout_float.close();

    // writing binary file for fix point hw accel
    std::ofstream fout_fix(basename + "_fix.binary", std::ios::out | std::ios::binary);
    fout_fix.write((char*)(&max_size), 4);

    char buffer[4*NUM_NODES] = {0};
    for(i = 0; i < max_size; ++i)
        for(j = 0; j < max_size; ++j)
        {
            char buffer_tmp[4];
            pt17[i][j].fillbuf(buffer);
            fout_fix.write(buffer, 4);
        }

    fout_fix.close();

    //FILE * fout = fopen(argv[2], "wb");
    //if(NULL == fout)
    //{
    //    printf("Error: unable to open %s\n", argv[2]);
    //    fclose(fin);
    //    return -3;
    //}

    //const int num_col = max_size;

    //fwrite((void *)(&num_col), sizeof(num_col), 1, fout);

    //for(i = 0; i < num_col; ++i)
    //    for(j = 0; j < num_col; ++j)
    //        fwrite((void *)(&t[i][j]), sizeof(t[i][j]), 1, fout);

    //fclose(fout);

    //fout.close();

    return 0;
}
