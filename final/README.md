# Page Rank Accelerator Design
### Final Project for EE382N.4 at UT Austin

This project implements accelerators for PageRank algorithm. There are 3 versions of accelerator design. 

    - RTL Accelerator Version 1: The first version of our custom designed accelerator. Contained under the subdirectory `accel_V1`. For more detailed instruction on how to build that accelerator, refer to the ReadMe under that sub-directory.
    - RTL Accelerator Version 2: The second version of the accelerator, which draws its design idea from the systolic array. This subproject now is still under test for now. For more informaiton, refer to that sub-directory
    - HLS Accelerator: an accelerator build from Xilinx HLS, refer to that directroy for information on how to build and test that project. 

The `sw` sub-directory contains a naive pure software implementation of the PageRank algorithm. Together with some other helper files(An sample code for how to run DMA on zynq)

For each sub-projects, under the subfolder contains the completely hardware and software code to build the whole system. For more details, refer to the ReadMes under those directories. 

The presentation slides is available [here](https://docs.google.com/presentation/d/1YrgV9XGWgNsmT-i3s5TgwWeNVSpzMtdd6_xbgWGxpgQ/edit?usp=sharing)

We are working on a more detailed report on this project, which is supposed to be available soon. 

The project is hosted at [https://github.com/SleepBook/EE382N4\_uController](https://github.com/SleepBook/EE382N4_uController)
