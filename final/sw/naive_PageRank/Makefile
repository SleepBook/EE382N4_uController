ALL:EXE

test:EXE
	./test arXiv384_float.binary 10

EXE:sw_naive.c
	gcc sw_naive.c -o test


.PHONY:clean

clean:
	-rm test
