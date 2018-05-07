KDIR = /usr/src/plnx_kernel
LIBPATH = $(KDIR)/lib
INCPATH = $(KDIR)/include 

CC := arm-linux-gnueabihf-gcc

PWD := $(shell pwd)
CFLAGS = -I $(INCPATH) -L $(LIBPATH)

default:
	$(CC) $(CFLAGS) hls_mv_demo.c -o hls_mv_demo

clean:
	rm hls_mv_demo
