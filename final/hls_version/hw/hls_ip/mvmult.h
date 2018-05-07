
#include <assert.h>
#include <ap_axi_sdata.h>

//#define DB_DEBUG


#define MCR_SIZE 16512
#define V_SIZE 128
typedef ap_axiu<32,4,5,5> AXI_VAL;

// function prototypes
void standalone_mvmult (float A[128][128], float B[128][1], float C[128][1]);
void HLS_mv (AXI_VAL in_stream[MCR_SIZE], AXI_VAL out_stream[V_SIZE]);



/* ****************************** C++ TEMPLATES ************************************** */

// reference function
template <typename T, int DIM1, int DIM2>
void matrix_vector_multiply_ref(T a[DIM1][DIM1], T b[DIM1][DIM2], T out[DIM1][DIM2])
{

	// matrix and vector multiplication of a A*B matrix
	for (int ia = 0; ia < DIM1; ++ia)
		for (int ib = 0; ib < DIM2; ++ib)
		{

			float sum = 0;

			for (int id = 0; id < DIM1; ++id)

				sum += a[ia][id] * b[id][ib];

			out[ia][ib] = sum;
		}

		return;
}

// --------------------------------------------------------
// function to be accelerated in HW
template <typename T, int DIM1, int DIM2>
void mvmult_hw(T a[DIM1][DIM1], T b[DIM1][DIM2], T out[DIM1][DIM2])
{

	//int const FACTOR = DIM/2;
	#pragma HLS INLINE
	//#pragma HLS array_partition variable=a block factor=FACTOR dim=2
	//#pragma HLS array_partition variable=b block factor=FACTOR dim=1

	// matrix multiplication of a A*B matrix
	L1:for (int ia = 0; ia < DIM1; ++ia)
		L2:for (int ib = 0; ib < DIM2; ++ib)
		{
			//#pragma HLS PIPELINE II=1
			T sum = 0;
			L3:for (int id = 0; id < DIM1; ++id)
				sum += a[ia][id] * b[id][ib];
			out[ia][ib] = sum;
		}

		return;
}

// --------------------------------------------------------
// functions to insert and extract elements from an axi stream
// includes conversion to correct data type

template <typename T, int U, int TI, int TD>
T pop_stream(ap_axiu <sizeof(T)*8,U,TI,TD> const &e)
{
#pragma HLS INLINE

	assert(sizeof(T) == sizeof(int));
	union
	{
		int ival;
		T oval;
	} converter;
	converter.ival = e.data;
	T ret = converter.oval;

	volatile ap_uint<sizeof(T)> strb = e.strb;
	volatile ap_uint<sizeof(T)> keep = e.keep;
	volatile ap_uint<U> user = e.user;
	volatile ap_uint<1> last = e.last;
	volatile ap_uint<TI> id = e.id;
	volatile ap_uint<TD> dest = e.dest;

	return ret;
}

template <typename T, int U, int TI, int TD> ap_axiu <sizeof(T)*8,U,TI,TD> push_stream(T const &v, bool last = false)
{
#pragma HLS INLINE
	ap_axiu<sizeof(T)*8,U,TI,TD> e;

	assert(sizeof(T) == sizeof(int));
	union
	{
		int oval;
		T ival;
	} converter;
	converter.ival = v;
	e.data = converter.oval;

	// set it to sizeof(T) ones
	e.strb = -1;
	e.keep = 15; //e.strb;
	e.user = 0;
	e.last = last ? 1 : 0;
	e.id = 0;
	e.dest = 0;
	return e;
}

// --------------------------------------------------------------------
// function to be accelerated in HW wrapped with AXI4-Stream interface

template <typename T, int DIM1, int DIM2, int SIZE, int U, int TI, int TD>
void wrapped_mvmult_hw (
	AXI_VAL in_stream[SIZE*SIZE + SIZE],
	AXI_VAL out_stream[SIZE])
{

#pragma HLS INLINE

	T a[DIM1][DIM1];
	T b[DIM1][DIM2];
	T out[DIM1][DIM2];

	assert(sizeof(T)*8 == 32);

	// stream in first matrix
	for(int i=0; i<DIM1; i++)
		for(int j=0; j<DIM1; j++)
		{
#pragma HLS PIPELINE II=1
			int k = i*DIM1+j;
			a[i][j] = pop_stream<T,U,TI,TD>(in_stream[k]);

		}

		// stream in second matrix
		for(int i=0; i<DIM1; i++)
			for(int j=0; j<DIM2; j++)
			{
#pragma HLS PIPELINE II=1
				int k = i*DIM2+j+SIZE*SIZE;
				b[i][j] = pop_stream<T,U,TI,TD>(in_stream[k]);
			}

			// do HW multiplication
			mvmult_hw<T, DIM1, DIM2>(a,b,out);

			// stream out result matrix
			for(int i=0; i<DIM1; i++)
				for(int j=0; j<DIM2; j++)
				{
					#pragma HLS PIPELINE II=1
					int k = i*DIM2+j;
					out_stream[k] = push_stream<T,U,TI,TD>(out[i][j],k == (SIZE-1));
				}
				return;

}



// test the functions
template <typename T, int DIM1, int DIM2, int SIZE, int U, int TI, int TD>
int test_matrix_mvult(void)
{
	int i,j, err;

	T matOp1[DIM1][DIM1];
	T matOp2[DIM1][DIM2];
	T matMult_sw[DIM1][DIM2];
	T matMult_hw[DIM1][DIM2];

	/** Matrix Initiation */
	for(i = 0; i<DIM1; i++)
		for(j = 0; j<DIM1; j++)
			matOp1[i][j] = (float)(i+j);

	for(i = 0; i<DIM1; i++)
		for(j = 0; j<DIM2; j++)
			matOp2[i][j] = (float)(i*j);
	/** End of Initiation */


	printf("DEBUGGING AXI4 STREAMING DATA TYPES!\r\n");

	// prepare data for the DUT
	AXI_VAL inp_stream[SIZE*SIZE + SIZE];
	AXI_VAL out_stream[SIZE];

	assert(sizeof(T)*8 == 32);
	// stream in the first input  matrix
	for(int i=0; i<DIM1; i++)
		for(int j=0; j<DIM1; j++)
		{
			int k = i*DIM1+j;
			inp_stream[k]      = push_stream<T,U,TI,TD>(matOp1[i][j],0);
		}
		// stream in the second input  matrix
		for(int i=0; i<DIM1; i++)
			for(int j=0; j<DIM2; j++)
			{
				int k = i*DIM2+j;
				inp_stream[k+SIZE*SIZE] = push_stream<T,U,TI,TD>(matOp2[i][j],k == (SIZE-1));
			}


			//call the DUT
			wrapped_mvmult_hw<T, DIM1, DIM2, SIZE, U, TI, TD>(inp_stream, out_stream);

			// extract the output matrix from the out stream 
			for(int i=0; i<DIM1; i++)
				for(int j=0; j<DIM2; j++)
				{
					int k = i*DIM2+j;
					matMult_hw[i][j] = pop_stream<T,U,TI,TD>(out_stream[k]);
				}


	/* reference Matrix Multiplication */
	matrix_vector_multiply_ref<T, DIM1, DIM2>(matOp1, matOp2, matMult_sw);

	/** Matrix comparison */
	err = 0;
	for (i = 0; (i<DIM1 && !err); i++)
		for (j = 0; (j<DIM2 && !err); j++)
			if (matMult_sw[i][j] != matMult_hw[i][j]) 
				err++;

	if (err == 0)
		printf("Matrixes identical ... Test successful!\r\n");
	else
		printf("Test failed!\r\n");

	return err;
}


