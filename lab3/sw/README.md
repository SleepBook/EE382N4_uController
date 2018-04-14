Lab 3
----------------

### Files
- README.md
- Makefile
- freq_test.sh
- repeat.sh
- sys_freq.c
- random.c
- mem_test.c
- measure_int.c
- lab1.c
- lab2.c
- dm.c
- pm.c
- main.c


### Design

#### HW

Hardware part is identical to lab2, you can refer to that design from here:

#### SW

##### Module freq_test
This module can be created with `make freq_test`, and described in the source file `sys_freq.c`

The purpose of this module is to setting the system's frequency. 

The module is implemented by accepting an integer variable between 1 - 8, which will index into an configuration table for the PLL_DIVIDER and Clock_DIVIDE which will decide the freqquency the system would be operating on. The table is shown as below:
|Index| PLL Divider | Clock Divider | System Speed |
|-----|-------------|---------------|--------------|
|  1  |      40     |       2       |   666 MHz    |
|  2  |      44     |       2       |   726 MHz    |
|  3  |      20     |      12       |    55 MHz    |
|  4  |      48     |       3       |   528 MHz    |
|  5  |      2      |       2       |    33 MHz    |
|  6  |      34     |      20       |  56.1 MHz    |
|  7  |      1      |       2       |  16.7 MHz    |
|  8  |      48     |       2       |   792 MHz    |

This module change the system speed following these precedures:
1. change ARM_PLL_CTRL[PLL_FDIV], ARM_PLL_CFG
2. ARM_PLL_CTRL [PLL_BYPASS_FORCE<4>] -> 1
3. ARM_PLL_CTRL [PLL_RESET] ->1 -> 0
4. Read PLL_STATUS [3] to verify
5. Change ARM_CLK_CTRL
6. ARM_PLL_CTRL [PLL_BYPASS_FORCE<4>] -> 0

Basically they are modifying two registers ARM_PLL_CFG and ARM_CLK_CTRL to their required value, force the PLL enter bypass mode, reset PLL and verify PLL is locked and finally disable PLL bypass. 

##### Module main.out

This module can be create by `make main.out` and is described by `main.c`. The purpose of this module is run the previous applicaiton of memory test and interrupt application at various system speed configuration. 


##### Scripts

`repeat.sh` and `freq_test.sh` can use the `freq_test` binary to change the configure of the system speed while waiting for ramdom amount of time in between. 


### Testing Process

Under the sw directory, do `make`, this will generate an executable `main.out`. Running this executable will do the test of dynamically change the speed of the system while testing the program of lab1 and lab2
