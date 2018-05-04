KDIR= /usr/src/plnx_kernel
LIBPATH=$(KDIR)/lib
INCPATH=$(KDIR)/include

CC := arm-linux-gnueabihf-gcc

PWD		:= $(shell pwd)
PTHREADFLAGS= -Wall -pthread
CFLAGS=  -I$(INCPATH) -L$(LIBPATH) $(PTHREADFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) $^ -c -o $@

main.out: main.o mem_test.o measure_int.o random.o pm.o dm.o
	$(CC) $(CFLAGS) $^ -o $@ -lm

freq_test: sys_freq.o dm.o pm.o random.o
	$(CC) $(CFLAGS) $^ -o $@

lab1.out: lab1.o random.o dm.o pm.o
	$(CC) $(CFLAGS) $^ -o $@

lab2.out: lab2.o random.o dm.o pm.o
	$(CC) $(CFLAGS) $^ -o $@ -lm

clean:
	rm -f *.o main.out freq_test

