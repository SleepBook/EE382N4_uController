### M6x6x2e12_V6x2e6_1.0

This is the folder for ip module M6x6x2e12_V6x2e6_1.0.
M6x6x2e12_V6x2e6 is the module to do matrix vector multiplication.
The throughput of M6x6x2e12_V6x2e6 is finishing the multiplication between 6x6 matrix and 6x1 vector per cycle.
The capacity of M6x6x2e12_V6x2e6 is up to handle a matrix with width of 6x2e6, namely 384x384 matrix.
The data type used in M6x6x2e12_V6x2e6 is 32-bit [single precision floating point](https://en.wikipedia.org/wiki/Single-precision_floating-point_format) following the IEEE 754 stadard.
Here only the customized hdl files are staged on github, to use this ip, a vivado project need to be setup with configured floating point cores, which could be found in [team drive](https://drive.google.com/open?id=1Z724Ml-CYQaENr1Vof71tvvKUlYALKQs).

#### References
 - [Zynq BRAM resources](https://www.xilinx.com/support/documentation/user_guides/ug473_7Series_Memory_Resources.pdf)
 - [Zynq Floating Point Core](https://www.xilinx.com/support/documentation/ip_documentation/floating_point/v7_1/pg060-floating-point.pdf)
