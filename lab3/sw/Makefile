KDIR= /usr/src/plnx_kernel
LIBPATH=$(KDIR)/lib
INCPATH=$(KDIR)/include

CC := arm-linux-gnueabihf-gcc

PWD		:= $(shell pwd)
PTHREADFLAGS= -Wall -pthread
CFLAGS=  -I$(INCPATH) -L$(LIBPATH) $(PTHREADFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) $^ -c -o $@

main.out: main.o mem_test.o measure_int.o
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm -f *.o main.out

