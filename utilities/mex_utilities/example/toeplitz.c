/*===========================================================================*
* toeplitz.c
* Fast Toeplitz matrix construction for full matrices.
*
* Copyright 2008 Levente Hunyadi
* All rights reserved.
*===========================================================================*/

#define __PACKAGENAME__ "math:toeplitz"
#include "common.c"

void toeplitz(const double* col, const double* row, double* toe, int m, int n) {
	const double* r, * c;
	int i, j;

	for (i = 0; i < n; i++) {
		r = row + i;
		for (j = i; j > 0; j--) {
			*(toe++) = *(r--);
		}

		c = col;
		for (j = i; j < m; j++) {
			*(toe++) = *(c++);
		}
	}
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
	const double* c;  /* first argument, column vector */
	int cn;
	const double* r;  /* second argument, row vector */
	int rn;
	double* t;  /* result, toeplitz matrix */

	/* check for proper number of input and output arguments */
	narginltechk(nrhs, 2);
	nargoutltechk(nlhs, 1);

	argdoublechk(prhs, 0);
	argrealchk(prhs, 0);
	argvectorchk(prhs, 0);
	argnonemptychk(prhs, 0);

	c = mxGetPr(prhs[0]);
	cn = mxGetNumberOfElements(prhs[0]);

	if (nrhs > 1) {
		argdoublechk(prhs, 1);
		argrealchk(prhs, 1);
		argvectorchk(prhs, 1);
		argnonemptychk(prhs, 1);

		r = mxGetPr(prhs[1]);
		rn = mxGetNumberOfElements(prhs[1]);
		if ( *c != *r ) {
			mexErrMsgIdAndTxt(__INVALIDVALUE__, "The first and second input argument vectors must start with the same element.");
		}
	} else {
		/* construct symmetric Toeplitz matrix */
		r = c;
		rn = cn;
	}

	/* call subroutine */
	plhs[0] = mxCreateDoubleMatrix(cn, rn, mxREAL);
	t = mxGetPr(plhs[0]);
	toeplitz(c, r, t, cn, rn);
}