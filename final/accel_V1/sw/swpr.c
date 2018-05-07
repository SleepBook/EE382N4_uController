#include <stdio.h>
#include <stdlib.h>

#define MAX_WIDTH  384

float m[MAX_WIDTH][MAX_WIDTH] = {0};
float v[MAX_WIDTH] = {0};
float r[MAX_WIDTH] = {0};

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

    if(3 > argc)
    {
        printf("Usage: %s <matrix.binary> <result.binary> [#iter]\n", argv[0]);
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
    char afloat[4];
    fread(afloat, 4, 1, fin);
    const int num_col = *((int *) afloat);
    printf("Expected Matrix Size %dx%d\n", num_col, num_col);
    for(i = 0; i < num_col; ++i)
        for(j = 0; j < num_col; ++j)
        {
            fread(afloat, 4, 1, fin);
            m[i][j] = *((float *) afloat);
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

    const float init_rank = 1.0 / num_col;
    float * pv;
    float * pr;
    for(idx = 0, pv = v; idx < num_col; ++idx)
    {
        pv[idx] = init_rank;
    }

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
            for(pr[i] = 0, j = 0; j < num_col; j+=6)
            {
                char buf[9];
                float s01, s23, s45, s03, s05;
                //printf("i = %d, j = %d\n", i, j);
                s01 = m[i][j] * pv[j] + m[i][j+1] * pv[j+1];
                //float2hex(s01, buf);
                //printf("s01: %s\n", buf);
                s23 = m[i][j+2] * pv[j+2] + m[i][j+3] * pv[j+3];
                //float2hex(s23, buf);
                //printf("s23: %s\n", buf);
                s45 = m[i][j+4] * pv[j+4] + m[i][j+5] * pv[j+5];
                //float2hex(s45, buf);
                //printf("s45: %s\n", buf);
                s03 = s01 + s23;
                //float2hex(s03, buf);
                //printf("s03: %s\n", buf);
                s05 = s03 + s45;
                //float2hex(s05, buf);
                //printf("s05: %s\n", buf);
                pr[i] += s05;
                //float2hex(pr[i], buf);
                //printf("pr[i]: %s\n", buf);
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

    /* print in floating point format to check */
    //printf("\nAfter %d iterations, the ranks are:\n", iter);
    //if(iter % 2)
    //{
    //    for(idx = 0; idx < num_col; ++idx)
    //        printf("%.5f ", r[idx]);
    //}
    //else
    //{
    //    for(idx = 0; idx < num_col; ++idx)
    //        printf("%.5f ", v[idx]);
    //}
    //printf("\n");

    FILE * fout = fopen(argv[2], "wb");
    if(NULL == fout)
    {
        printf("Error: unable to open %s\n", argv[3]);
        return -7;
    }
    fwrite((void*)(&num_col), sizeof(num_col), 1, fout);
    if(iter % 2)
        fwrite((void*)(r), sizeof(r[0]), num_col, fout);
    else
        fwrite((void*)(v), sizeof(v[0]), num_col, fout);
    fclose(fout);

    return 0;
}
