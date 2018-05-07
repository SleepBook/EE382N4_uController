CFLAGS :=

CC := gcc

PWD		:= $(shell pwd)

%.o: %.cpp
	$(CC) $(CFLAGS) $^ -c -o $@

swpr: swpr.c
	$(CC) $(CFLAGS) $^ -o $@

testPR: testPR.c
	$(CC) $(CFLAGS) $^ -o $@

testPR_timing: testPR_timing.c
	$(CC) $(CFLAGS) $^ -o $@

testdmamv: testdmamv.c adapter.h 382dma.h adapter.o 382dma.o
	$(CC) $(CFLAGS) $^ -o $@
timing: testdmamv_timing.c adapter.h 382dma.h adapter.o 382dma.o
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm -f *.o

