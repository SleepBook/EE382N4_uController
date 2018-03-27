Lab 2
-----

### Files

- README.md
- sw/kernel\_module/Makefile
- sw/kernel\_module/pl\_int\_ker.c
- sw/measure\_int.c
- hw/lab2.tar.gz
- hw/ip\_repo.tar.gz
- res/measure\_w\_load.csv
- res/measure\_wo\_load.csv
- res/latencices.png

### Design

#### Hardware

##### IP of int\_latency

We packaged a new IP module, int\_latency to replaced the AXI gpio module used in lab 1.
The LSB (Least Significant Bit) of `slv_reg0` is used for software to raise interrupt.
, whose offset is 0, serves as DR (Data Register).
The pseudo-random value generated is put into DR, so PS (Processing System) can read it later.
The `slv_reg2`, whose offset is 8, serves as CR (Control Register).
Only the LSB (Least Significant Bit) of CR is used to trigger LFSR to shift once.

##### Top design

In the top block diagram, we instanced one LFSR10 and one LFSR32 as what we do in lab 1.
Also we instanced one int\_latency module.
Via AXI Interconnect module, all of them are connected to PS.
The address assignments are listed in the following table.

| Module        | Address Base | Range |
|---------------|--------------|-------|
| LFSR10        | 0x43C00000   | 4k    |
| LFSR32        | 0x43C01000   | 4k    |
| int\_latency  | 0x43C10000   | 4k    |
| bram\_ctrl\_0 | 0x40000000   | 8k    |
| bram\_ctrl\_1 | 0x40002000   | 8k    |

#### Software

##### Building System and Version Control

To better collaborate on software development, we use git as version control system, and put all our software code on a [github repository](https://github.com/SleepBook/EE382N4_uController/tree/master/lab2).
Besides, to keep the folder clear and organized, we use make as building system.

##### Kernel Module

Unlike lab 1, we designed a kernel module for the new peripheral, so that user application could use system call to finish its measurement, instead of executing in privilege mode to do memory map.

The source file for our kernel module is `sw/kernel\_module/pl\_int\_ker.c`.
The functions and their functionalities are listed as follows.

1. `static int __init init_fpga_int(void)` module initialize function;
2. `static void __exit cleanup_fpga_int(void)` module exit function;
3. `irqreturn_t interrupt_handler(int irq, void *dev_id)` interrupt handler;
4. `static int fpga_int_open (struct inode *inode, struct file *file)` file operation function to handle open;
5. `static int fpga_int_release (struct inode *inode, struct file *file)` file operation function to handle close;
6. `static int fpga_int_fasync (int fd, struct file *filp, int on)` file operation function to handle asynchronous signal queue manipulate;
7. `ssize_t fpga_int_read (struct file * pf, char * usr_buf, char * usr_buf, size_t len, loff_t * offset)` file operation function to handle read;
8. `ssize_t fpga_int_write ( struct file * pf, const char * usr_buf, size_t len, loff_t * offset)` file operation function to handle write;

The function `init_fpga_int()` has 7 steps to setup everything for the interrupt kernel:
0. `proc_create()` creates an entry under `/proc` to store any runtime system information needed by the interrupt handler;
1. `alloc_chrdev_region()` picks an available device number and register this kernel module as the driver for that device;
2. `class_create()` creates a device class associated to the kernel module;
3. `device_create()` creates a device using that device number allocated before;
4. `cdev_init()` initializes the device with the file operation structure `fpga_int_fops`, so that the operations like open, read, write are mapped to functions listed in the `fpga_int_fops`;
5. `request_irq()` requests an interrupt number from Linux, which is then binded to the hardware interrupt id 164, and the interrupt handler is associated to be invoked when the interrupt comes;
6. `ioremap()` maps a page of virtual addresses to a physical frame, so that the file operation functions could easily access the phsical registers by the virtual address base plus offset;

The exit function does the series of work in a reverse way, for example, release the mapping, interrupt number, then destroy the device, device class proc entry.

Among the five file operation functions, open and release functions do nothing but helping debugging and reset file cursor offset.

The `fpga_int_fasync()` function serves as hook which would be invoked when a process calls `fcntl()` to claim the ownership of asynchronous signal from this device.
We did nothing here, but a print for debug.

The `fpga_int_read()` function fills the user buffer with specified number of bytes from registers, and it would move the file cursor forward as well.
The `fpga_int_write()` function takes the value from user buffer and sets the registers properly.
The write function does not move the file cursor for convenience.

##### Measuring Program

Our measuring program does 300 times measurement, which is consit of `NUM_MEASUREMENTS` samples.
The procedure is as follows:

1. Bind interrupt handler with `SIGIO` signal;
2. Open `/dev/fpga_int` and add the process itself into the device's asynchronous signal queue;
3. Initialize a series of variables for statistics, as well as prepare the csv file to record results;
4. Start 300 iterations of the outer loop;
5. Start `NUM_MEASUREMENTS` iterations of the inner loop;
6. Backup the signal mask and set an empty mask to block all the signals;
7. Take a start time via function `gettimeofdaty()`, and raise a software by writing 1 to `/dev/fpga_int`;
8. Suspend process with a mask which only allows `SIGIO` to pass in;
9. Once the signal comes in and the handler get exercised, the process moves on to restore the signal mask;
10. Record the latency by subtract the start time from the timestampe taken in the handler functions;
11. Repeat step 5 to step 10 for `NUM_MEASUREMENTS` times, then calculate the statistics for those samples, then print out;
12. Sleep for 1 second;
13. Repeat step 4 to step 12 for 300 times;

### Testing Process

Under sw folder, execute:
``` bash
make measure_int
```
An executable file called measure\)int should be compiled.
To measure the latency, use the following command to execute it:
``` bash
./measure_int
```
During the execution, every `NUM_MEASUREMENTS` interrupts, it would print out statistics to terminal showing information like mean, max, min, stdev etc.
And a file called `measure_int.csv` would be created in the same folder to hold the record for each measurement.

There are two example csv files included in the res subfolder, one for measuring the latency with load, another for without load.
And a plot based on the data in those two files is include in the res subfolder as well.

