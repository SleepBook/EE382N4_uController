#include <stdio.h>
#include <stdlib.h>

#include "mvmult.h"

typedef float T;
int const DIM1 = 128;
int const DIM2 = 1;
int const SIZE = 128;


void mvmult_sw(T a[DIM1][DIM1], T b[DIM1][DIM2], T out[DIM1][DIM2])
{
	// matrix multiplication of a A*B matrix
	for (int ia = 0; ia < DIM1; ++ia)
		for (int ib = 0; ib < DIM2; ++ib)
		{

			float sum = 0;

			for (int id = 0; id < DIM1; ++id)

				sum += a[ia][id] * b[id][ib];

			out[ia][ib] = sum;
		}
}


#ifdef DB_DEBUG

int main(void)
{

	int ret_val = 0;

	ret_val = test_matrix_mvult<T, DIM1, DIM2, SIZE, 4,5,5>();

	return ret_val;

}

#else

int main(void)
{

	int ret_val = 0;

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

	printf("NORMAL MODE\r\n");
	standalone_mvmult(matOp1, matOp2, matMult_hw);

	/* reference Matrix Multiplication */
	mvmult_sw(matOp1, matOp2, matMult_sw);

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



#endif
