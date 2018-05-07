CFLAGS := -std=c++11

CC := g++

PWD		:= $(shell pwd)

%.o: %.cpp
	$(CC) $(CFLAGS) $^ -c -o $@

tsv2binary: tsv2binary.cpp point17.o
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm -f *.o

