#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define MAX_WIDTH  384

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

#define MBRAM_CTRL 0x43C00000
#define MBRAM_BASE 0x43C01000
#define VBRAM_CTRL 0x43C02000
#define VBRAM_BASE 0x43C03000
#define MV_BASE    0x43C04000

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
    int iter;
    int i, j, idx;
    struct timeval origin, tofeedM, tofeedV, tocompute, toreadback, end;

    gettimeofday(&origin, NULL);

    if(3 > argc)
    {
        printf("Usage: %s <matrix.binary> <result.binary> [#iter]\n", argv[0]);
        return -1;
    }
    else if(3 < argc)
        iter = atoi(argv[3]);
    else
        iter = 1;

    FILE * fin = fopen(argv[1], "rb");
    if(NULL == fin)
    {
        printf("Error: unable to read %s \n", argv[1]);
        return -2;
    }
    char afloat[4];
    fread(afloat, 4, 1, fin);
    const int num_col = *((int *) afloat);
    const int padding = (num_col % 6)?(6 - (num_col % 6)):0;
    const int width = num_col + padding;
    //printf("Expected Matrix Size %dx%d\n", num_col, num_col);
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
    //for(i = 0; i < width; i+=6)
    //    for(j = 0; j < width; j+=6)
    //    {
    //        for(idx = 0; idx < 36; ++idx)
    //        {
    //            char buf[9];
    //            float2hex(m[i+idx/6][j+idx%6], buf);
    //            printf("%s", buf);
    //            if(5 == idx%6)
    //                printf("\n");
    //            else
    //                printf(" ");
    //        }
    //        printf("\n");
    //    }

    for(idx = 0; idx < num_col; ++idx)
        v[idx] = 1.0 / num_col;

    /* check vector 6 per line */
    //for(i = 0; i < width; i+=6)
    //{
    //    for(idx = 0; idx < 6; ++idx)
    //    {
    //        char buf[9];
    //        float2hex(v[i+idx], buf);
    //        printf("%s", buf);
    //        if(5 == idx%6)
    //            printf("\n");
    //        else
    //            printf(" ");
    //    }
    //    printf("\n");
    //}
    //*/

    // Computation starts from here
    /*
     * Open Phy Mem
     */
    int fd = open("/dev/mem", O_RDWR|O_SYNC);
    if(fd == -1){
        printf("unable to open /dev/mem\n");
        return -8;
    }

    /*
     * DO memory Maping
     */

    unsigned int * mbram_ctrl;
    float * mbram_base;
    unsigned int * vbram_ctrl;
    float * vbram_base;
    unsigned int * mv_base;

    mbram_ctrl = (unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            MBRAM_CTRL & ~MAP_MASK
            );
    //printf("\nmbram_ctrl: 0x%08X => %p\n", MBRAM_CTRL, mbram_ctrl);
    mbram_base = (float *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            MBRAM_BASE & ~MAP_MASK
            );
    //printf("\nmbram_base: 0x%08X => %p\n", MBRAM_BASE, mbram_base);
    vbram_ctrl = (unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            VBRAM_CTRL & ~MAP_MASK
            );
    //printf("\nvbram_ctrl: 0x%08X => %p\n", VBRAM_CTRL, vbram_ctrl);
    vbram_base = (float *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            VBRAM_BASE & ~MAP_MASK
            );
    //printf("\nvbram_base: 0x%08X => %p\n", VBRAM_BASE, vbram_base);
    mv_base = (unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            MV_BASE & ~MAP_MASK
            );
    //printf("\nmv_base:    0x%08X => %p\n", MV_BASE, mv_base);

    gettimeofday(&tofeedM, NULL);
    unsigned int ctrl_wr = 0x00000011;
    for(i = 0; i < width; i+=6)
        for(j = 0; j < width; j+=6)
        {
            for(idx = 0; idx < 36; ++idx)
            {
                mbram_base[idx] = m[i+idx%6][j+idx/6];
            }
            *mbram_ctrl = ctrl_wr;
            ctrl_wr += 0x00000100;  // increase memory index
        }
    gettimeofday(&tofeedV, NULL);
    ctrl_wr = 0x00000011;
    for(i = 0; i < width; i+=6)
    {
        for(idx = 0; idx < 6; ++idx)
        {
            vbram_base[idx] = v[i+idx];
        }
        *vbram_ctrl = ctrl_wr;
        ctrl_wr += 0x00000100;  // increase memory index
    }
    gettimeofday(&tocompute, NULL);
    // trigger the mv module to compute
    *mv_base = (iter << 16) | (width << 4) | 0x00000001;
    // wait until computation finish
    while((*mv_base)&0x00000001);
    //sleep(1);
    // read out the result
    gettimeofday(&toreadback, NULL);
    unsigned int ctrl_rd = 0x00020001;
    if(iter % 2)
        ctrl_rd = 0x00020001;
    else
        ctrl_rd = 0x00000001;
    for(i = 0; i < num_col; i+=6)
    {
        *vbram_ctrl = ctrl_rd;
        for(idx = 0; idx < 6; ++idx)
        {
            r[i+idx] = vbram_base[idx];
        }
        ctrl_rd += 0x00000100;  // increase memory index
    }

    munmap(mbram_ctrl, MAP_SIZE);
    munmap(mbram_base, MAP_SIZE);
    munmap(vbram_ctrl, MAP_SIZE);
    munmap(vbram_base, MAP_SIZE);
    munmap(mv_base, MAP_SIZE);

    close(fd);

    FILE * fout = fopen(argv[2], "wb");
    if(NULL == fout)
    {
        printf("Error: unable to open %s\n", argv[2]);
        return -7;
    }
    fwrite((void*)(&num_col), sizeof(num_col), 1, fout);
    fwrite((void*)(r), sizeof(r[0]), num_col, fout);
    fclose(fout);

    gettimeofday(&end, NULL);

    /* check vector 6 per line */
    //for(i = 0; i < width; i+=6)
    //{
    //    for(idx = 0; idx < 6; ++idx)
    //    {
    //        printf("%.5f", r[i+idx]);
    //        if(5 == idx%6)
    //            printf("\n");
    //        else
    //            printf(" ");
    //    }
    //    printf("\n");
    //}

    long feedM_time = tofeedV.tv_sec*1000000 + tofeedV.tv_usec - tofeedM.tv_sec*1000000 - tofeedM.tv_usec;
    long feedV_time = tocompute.tv_sec*1000000 + tocompute.tv_usec - tofeedV.tv_sec*1000000 - tofeedV.tv_usec;
    long compute_time = toreadback.tv_sec*1000000 + toreadback.tv_usec - tocompute.tv_sec*1000000 - tocompute.tv_usec;
    long total_time = end.tv_sec*1000000 + end.tv_usec - origin.tv_sec*1000000 - origin.tv_usec;

    printf("Feed Matrix: %ld us\n", feedM_time);
    printf("Feed Vector: %ld us\n", feedV_time);
    printf("Computation: %ld us\n", compute_time);
    printf("Total Exec : %ld us\n", total_time);

    return 0;
}
