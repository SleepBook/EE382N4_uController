KDIR= /usr/src/plnx_kernel
LIBPATH=$(KDIR)/lib
INCPATH=$(KDIR)/include

CC := arm-linux-gnueabihf-gcc

obj-m += dma_test.o

PWD:= $(shell pwd)

default:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	make -C $(KDIR) M=$(PWD) clean


