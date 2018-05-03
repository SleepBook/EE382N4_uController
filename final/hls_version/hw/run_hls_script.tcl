############################################################
## This file is generated automatically by Vivado HLS.
## Please DO NOT edit it.
## Copyright (C) 2012 Xilinx Inc. All rights reserved.
############################################################
#config_interface -trim_dangling_port

# WRAPPED AXI4-STREAM MATRIX MULTIPLIER HLS PROJECT
open_project -reset hls_wrapped_mvmult_prj
set_top HLS_mv_t
add_files mvmult_accel.cpp -cflags "-DDB_DEBUG"
add_files -tb mvmult_test.cpp -cflags "-DDB_DEBUG"

open_solution -reset "solution0"
set_part {xc7z020clg484-1}
create_clock -period 10 -name default
set_directive_inline "mvmult_hw"
set_directive_pipeline -II 1 "mvmult_hw/L1"
set_directive_pipeline -II 1 "mvmult_hw/L3"
set_directive_array_partition -type block -factor 16 -dim 2 "mvmult_hw" a
set_directive_array_partition -type block -factor 16 -dim 1 "mvmult_hw" b
csim_design -clean
#-setup
csynth_design

open_solution -reset "solution1"
set_part {xc7z020clg484-1}
create_clock -period 10 -name default
set_directive_inline "mvmult_hw"
set_directive_pipeline -II 1 "mvmult_hw/L1"
set_directive_pipeline -II 1 "mvmult_hw/L3"
set_directive_array_partition -type block -factor 32 -dim 2 "mvmult_hw" a
set_directive_array_partition -type block -factor 32 -dim 1 "mvmult_hw" b
csim_design -clean
#-setup
csynth_design

#export_design -evaluate verilog -format ip_catalog 
close_project
