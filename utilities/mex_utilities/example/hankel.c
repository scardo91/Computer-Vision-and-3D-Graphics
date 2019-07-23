/*===========================================================================*
* hankel.c
* Fast Hankel matrix construction for full matrices.
*
* Copyright 2008 Levente Hunyadi
* All rights reserved.
*===========================================================================*/

#define __PACKAGENAME__ "math:hankel"
#include "common.c"

void hankel(const double* col, const double* row, double* han, int m, int n) {
	const double* c, * r;
	int i, j;

	row++;  /* first element of row always matches last element of column */
	for (i = 0; i < n; i++) {
		c = col + i;
		for (j = i; j < m; j++) {
			*(han++) = *(c++);
		}
		r = row;
		if (i > m) {
			r += i-m;
		}
		for (j = 0; j < i; j++) {
			*(han++) = *(r++);
		}
	}
}

void hankel_upper(const double* col, double* han, int m) {
	const double* c;
	int i, j;

	for (i = 0; i < m; i++) {
		c = col + i;
		for (j = i; j < m; j++) {
			*(han++) = *(c++);
		}
		han += i;
	}
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
	const double* c;
	int cn;
	double* h;

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
		const double* r;
		int rn;

		argdoublechk(prhs, 1);
		argrealchk(prhs, 1);
		argvectorchk(prhs, 1);
		argnonemptychk(prhs, 1);

		r = mxGetPr(prhs[1]);
		rn = mxGetNumberOfElements(prhs[1]);

		if ( c[cn-1] != r[0] ) {
			mexErrMsgIdAndTxt(__INVALIDVALUE__, "The second input argument vector must start with the last element of the first.");
		}

		/* call subroutine */
		plhs[0] = mxCreateDoubleMatrix(cn, rn, mxREAL);
		h = mxGetPr(plhs[0]);
		hankel(c, r, h, cn, rn);
	} else {
		plhs[0] = mxCreateDoubleMatrix(cn, cn, mxREAL);
		h = mxGetPr(plhs[0]);
		hankel_upper(c, h, cn);
	}
}