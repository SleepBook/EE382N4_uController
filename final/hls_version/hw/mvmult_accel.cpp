#include <stdio.h>
#include <stdlib.h>

#include "mvmult.h"


// THIS IS THE TOP LEVEL DESIGN THAT WILL BE SYNTHESIZED
#define MCR_SIZE 16512
#define V_SIZE 128


void standalone_mvmult (float A[128][128], float B[128][1], float C[128][1])
{

	mvmult_hw <float, 128, 1>(A, B, C);

}



//void HLS_accel (AXI_VAL in_stream[2*MCR_SIZE], AXI_VAL out_stream[MCR_SIZE])
void HLS_mv_t (AXI_VAL INPUT_STREAM[MCR_SIZE], AXI_VAL OUTPUT_STREAM[V_SIZE])
{
#pragma HLS INTERFACE s_axilite port=return     bundle=CONTROL_BUS
#pragma HLS INTERFACE axis      port=OUTPUT_STREAM
#pragma HLS INTERFACE axis      port=INPUT_STREAM

// HLS DEPRECATED MODE
//	// Map ports to Vivado HLS interfaces 
//	#pragma HLS INTERFACE ap_fifo port=in_stream
//	#pragma HLS INTERFACE ap_fifo port=out_stream
//	// Map HLS ports to AXI interfaces
//	#pragma HLS RESOURCE variable=in_stream  core=AXIS metadata="-bus_bundle INPUT_STREAM"
//	#pragma HLS RESOURCE variable=out_stream core=AXIS metadata="-bus_bundle OUTPUT_STREAM"
//	#pragma HLS RESOURCE variable=return core=AXI4LiteS metadata="-bus_bundle CONTROL_BUS"

	wrapped_mvmult_hw <float, 128, 1, 128, 4, 5, 5>(INPUT_STREAM, OUTPUT_STREAM);

	return;
}

