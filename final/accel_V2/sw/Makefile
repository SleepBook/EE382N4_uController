CFLAGS := -std=c++11

CC := g++

PWD		:= $(shell pwd)

%.o: %.cpp
	$(CC) $(CFLAGS) $^ -c -o $@

main.out: main.cpp point17.o
	$(CC) $(CFLAGS) $^ -o $@

test.out: test.cpp point17.o
	$(CC) $(CFLAGS) $^ -o $@

print.out: print.cpp point17.o
	$(CC) $(CFLAGS) $^ -o $@

fillbuf.out: fillbuf.cpp point17.o
	$(CC) $(CFLAGS) $^ -o $@

tsv2binary: tsv2binary.cpp point17.o
	$(CC) $(CFLAGS) $^ -o $@

swpr: swpr.cpp point17.o
	$(CC) $(CFLAGS) $^ -o $@

testfix: testfix.cpp point17.o
	$(CC) $(CFLAGS) $^ -o $@

clean:
	rm -f *.o test.out main.out

