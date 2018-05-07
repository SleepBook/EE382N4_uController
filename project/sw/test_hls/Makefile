KDIR = /usr/src/plnx_kernel
LIBPATH = $(KDIR)/lib
INCPATH = $(KDIR)/include 
INCPATH2 = $(KDIR)/arch/arm/include

CC := arm-linux-gnueabihf-gcc

PWD := $(shell pwd)
CFLAGS = -I $(INCPATH) -I $(INCPATH2) -L $(LIBPATH)

default:
	$(CC) $(CFLAGS) main.c -o test_mm

test_mv:
	$(CC) $(CFLAGS) test_mv.c -o test_mv

test_mv_t:
	$(CC) $(CFLAGS) test_mv_t.c -o test_mv_t

test_pr:
	$(CC) $(CFLAGS) pr.c -o test_pr

testhls: testhls.c
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm test_mm test_mv test_mv_t
