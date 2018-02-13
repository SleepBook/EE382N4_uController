Lab 1
-----

### Files

- README.md
- sw/Makefile
- sw/mem\_test.c
- hw/lab1.tar.gz

### Design

#### Hardware

##### IP of LFSR (Linear Feedback Shift Register)

We packaged two IP modules: LFSR10 and LFSR32, which are 10-bit LFSR and 32-bit LFSR respectively.
Both of them use AXI-lite protocal.
The `slv_reg0`, whose offset is 0, serves as DR (Data Register).
The pseudo-random value generated is put into DR, so PS (Processing System) can read it later.
The `slv_reg2`, whose offset is 8, serves as CR (Control Register).
Only the LSB (Least Significant Bit) of CR is used to trigger LFSR to shift once.

##### Top design

In the top block diagram, we instanced one LFSR10 and one LFSR32.
Via AXI Interconnect module, they are connected to PS.
The addresses assigned to LFSR10 and LFSR32 are 0x43C00000 and 0x43C01000 respectively.

#### Software

##### Building System and Version Control

To better collaborate on software development, we use git as version control system, and put all our software code on a github repository.
Besides, to keep the folder clear and organized, we use make as building system.

##### Test Program

Our test program takes dm.c and pm.c as examples.
The idea to access block RAM, LFSRs and GPIO peripheral is as following:

1. Open the device node `/dev/mem`;
2. Map physical memory space of those peripherals to a virtual page (`mmap()` would return a pointer to the base address of the page);
3. Access peripheral registers as elements of an array (calculate index according to address offset);

The idea to add a random delay between the write and read on one address is couting down from a random value then read back upon timeout.
To implement the idea, we have an 1024-element array in the C code:`cell status[TEST_LENGTH]` to hold the time left for each address.
It will be set a random value on writing the the corresponding entry of block RAM.
And every loop, every non-zero element in the array decrements one.
If the count equals one, do read in this iteration.

### Testing Process

Under sw folder, execute:
``` bash
make test
```
An executable file called test should be compiled.
It requests two command line arguments.
First to specify the write port, and the second for read port.
For example to test writing to B port then reading from port A:
``` bash
./test b a
```

A file called `report.txt` would be created in the same folder to indicate the whether the memory test is passed or not.
Another file called `log.txt` would be created to hold the diagnostics.
Additionally, the eight LEDs on the board would count the number of passed tests.
But if there is one test failed, it gets cleared, which means all the LEDs are off.

