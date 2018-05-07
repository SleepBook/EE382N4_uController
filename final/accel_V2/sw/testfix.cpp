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

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

#define VBRAM0_CTRL 0x43C00000
#define VBRAM0_BASE 0x43C01000
#define VBRAM1_CTRL 0x43C02000
#define VBRAM1_BASE 0x43C03000
#define MBRAM_CTRL  0x43C04000
#define MBRAM_BASE  0x43C05000
#define FIXED_MV_BASE  0x43C10000


Point17 m[MAX_WIDTH][MAX_WIDTH];
//Point17 v[MAX_WIDTH];
Point17 r[MAX_WIDTH];
Point17 init_rank;

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
    int num_nodes = 64;
    int i, j, idx;
    double pri;
    struct timeval origin, tofeedM, tofeedV, tocompute, toreadback, end;
    gettimeofday(&origin, NULL);

    if(3 > argc)
    {
        printf("Usage: %s <matrix_fix.binary> <result.binary> [#iter] [#node]\n", argv[0]);
        return -1;
    }
    else if (4 < argc)
    {
        iter = atoi(argv[3]);
        num_nodes = atoi(argv[4]);
    }
    else if (3 < argc)
    {
        iter = atoi(argv[3]);
    }

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
            //std::cout << std::hex << aint;
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

    init_rank = 1.0 / num_col;

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

    volatile unsigned int * mbram_ctrl;
    volatile unsigned int * mbram_base;
    volatile unsigned int * vbram0_ctrl;
    volatile unsigned int * vbram0_base;
    volatile unsigned int * vbram1_ctrl;
    volatile unsigned int * vbram1_base;
    volatile unsigned int * fixed_mv_base;

    mbram_ctrl = (volatile unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            MBRAM_CTRL & ~MAP_MASK
            );
    //printf("\nmbram_ctrl: 0x%08X => %p\n", MBRAM_CTRL, mbram_ctrl);
    mbram_base = (volatile unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            MBRAM_BASE & ~MAP_MASK
            );
    //printf("\nmbram_base: 0x%08X => %p\n", MBRAM_BASE, mbram_base);
    vbram0_ctrl = (volatile unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            VBRAM0_CTRL & ~MAP_MASK
            );
    //printf("\nvbram0_ctrl: 0x%08X => %p\n", VBRAM0_CTRL, vbram0_ctrl);
    vbram0_base = (volatile unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            VBRAM0_BASE & ~MAP_MASK
            );
    //printf("\nvbram0_base:   0x%08X => %p\n", VBRAM0_BASE, vbram0_base);
    vbram1_ctrl = (volatile unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            VBRAM1_CTRL & ~MAP_MASK
            );
    //printf("\nvbram1_ctrl:   0x%08X => %p\n", VBRAM1_CTRL, vbram1_ctrl);
    vbram1_base = (volatile unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            VBRAM1_BASE & ~MAP_MASK
            );
    //printf("\nvbram1_base:   0x%08X => %p\n", VBRAM1_BASE, vbram1_base);
    fixed_mv_base = (volatile unsigned int *)mmap(
            NULL,
            MAP_SIZE,
            PROT_READ|PROT_WRITE,
            MAP_SHARED,
            fd,
            FIXED_MV_BASE & ~MAP_MASK
            );
    //printf("\nfixed_mv_base: 0x%08X => %p\n", FIXED_MV_BASE, fixed_mv_base);

    gettimeofday(&tofeedM, NULL);
    unsigned int ctrl_wr = 0x00000011;
    for(i = 0; i < num_col; i += num_nodes)
        for(j = 0; j < num_col; ++j)
        {
            for(idx = 0; idx < num_nodes; ++idx)
            {
                mbram_base[idx] = m[i+idx][j];
                //std::cout << "\t" << i << "\t" << j << "\t" << idx << "\t";
                //std::cout << std::hex << mbram_base[idx] << std::endl;
                //std::cout << m[i+idx][j] << std::endl;
            }
            *mbram_ctrl = ctrl_wr;
            ctrl_wr += 0x00000100;  // increase memory index
        }

    gettimeofday(&tofeedV, NULL);
    fixed_mv_base[1] = init_rank;
    gettimeofday(&tocompute, NULL);

    //std::cout << fixed_mv_base[1] << std::endl;
    //while(1);

    // Computation starts from here
    *fixed_mv_base = ((iter+1) << 16) | (num_col << 4) | 0x00000001;
    while(*fixed_mv_base & 0x00000001);
    while(*fixed_mv_base & 0x00000001);

    gettimeofday(&toreadback, NULL);
    volatile unsigned int * vbram_ctrl;
    volatile unsigned int * vbram_base;
    if(iter % 2)
    {
        vbram_ctrl = vbram0_ctrl;
        vbram_base = vbram0_base;
    }
    else
    {
        vbram_ctrl = vbram1_ctrl;
        vbram_base = vbram1_base;
    }
    unsigned int ctrl_rd = 0x00000001;
    const unsigned int cutoff_addr =
        (num_col % num_nodes) ?
        num_col - (num_col % num_nodes) :
        num_col - num_nodes;
    for(idx = 0; idx < cutoff_addr; ++idx)
    {
        *vbram_ctrl = ctrl_rd;
        r[idx] = *vbram_base;
        ctrl_rd += 0x00000100;  // increase memory index
    }
    if(iter % 2)
    {
        vbram_ctrl = vbram1_ctrl;
        vbram_base = vbram1_base;
    }
    else
    {
        vbram_ctrl = vbram0_ctrl;
        vbram_base = vbram0_base;
    }
    for(; idx < num_col; ++idx)
    {
        *vbram_ctrl = ctrl_rd;
        r[idx] = *vbram_base;
        ctrl_rd += 0x00000100;  // increase memory index
    }

    std::ofstream fout(argv[2], std::ios::binary | std::ios::out);

    fout.write((char*)&num_col, sizeof(num_col));

    for(i = 0; i < num_col; ++i)
    {
        fout << r[i];
    }

    fout.close();

    munmap((void*)mbram_ctrl, MAP_SIZE);
    munmap((void*)mbram_base, MAP_SIZE);
    munmap((void*)vbram0_ctrl, MAP_SIZE);
    munmap((void*)vbram0_base, MAP_SIZE);
    munmap((void*)vbram1_ctrl, MAP_SIZE);
    munmap((void*)vbram1_base, MAP_SIZE);
    munmap((void*)fixed_mv_base, MAP_SIZE);

    gettimeofday(&end, NULL);

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
