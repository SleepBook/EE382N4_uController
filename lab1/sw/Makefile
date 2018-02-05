KDIR= /usr/src/linux-3.10.17.1
LIBPATH=$(KDIR)/lib
INCPATH=$(KDIR)/include

CC := arm-linux-gnueabihf-gcc

PWD		:= $(shell pwd)
CFLAGS=  -I$(INCPATH) -L$(LIBPATH)

test:
	$(CC) $(CFLAGS) mem_test.c  -o $@

.PHONY: clean
clean:
	-rm test *.txt

