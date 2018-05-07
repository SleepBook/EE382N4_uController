### accel\_V1/sw

This is the folder to hold the software programs, scripts used with the first verion of accelerator design.

#### files
- README.md
- Makefile
- testdmamv.c - page rank application ran with dmamv\_v8.bit
- testdmamv\_timing.c - variation of testdmamv.c for timing purpose
- testPR.c - page rank application ran with mv\_v11.bit
- testPR\_timing.c - variation of testPR.c for timing purpose
- 382dma.h
- 382dma.c - dma driver
- adapater.h
- adapater.c - axis to bram adapater driver
- swpr.c - software page rank for debugging
- cleanmvbram.sh - used with mv\_v11.bit to clean matrix, vector bram
- order.py - script to sort the pages according their ranks
