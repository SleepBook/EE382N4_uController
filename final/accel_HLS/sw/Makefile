CC := gcc
CFLAGS := 

test_mv:
	$(CC) $(CFLAGS) test_mv.c -o test_mv

test_mv_t:
	$(CC) $(CFLAGS) test_mv_t.c -o test_mv_t

test_pr:
	$(CC) $(CFLAGS) pr.c -o test_pr

testhls: testhls.c
	$(CC) $(CFLAGS) $^ -o $@

timing: testhls_timing.c
	$(CC) $(CFLAGS) $^ -o $@

clean:
	-rm test_mm test_mv test_mv_t test_pr testhls timing
