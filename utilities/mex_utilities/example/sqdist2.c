/*===========================================================================*
* sqdist2.c
* Squared Euclidean distance.
*
* Copyright 2008-2009 Levente Hunyadi
* All rights reserved.
*===========================================================================*/

#define __PACKAGENAME__ "math:sqdist2"
#include "common.c"

/**
* Euclidean distance of two vectors.
*/
mxArray* distvecvec(const mxArray* vec1, const mxArray* vec2) {
	const double* p1 = mxGetPr(vec1);
	const double* p2 = mxGetPr(vec2);
	
	int N1 = mxGetNumberOfElements(vec1);
	int N2 = mxGetNumberOfElements(vec2);

	double r = 0.0;
	mxArray* res;

	int k;

	if (N1 != N2) {
		mexErrMsgIdAndTxt(__DIMENSIONMISMATCH__, "Input argument vectors must have the same number of elements.");
	}

	for (k = 0; k < N1; k++) {
		double d = *(p1++) - *(p2++);
		r += d*d;
	}

	/* place result in output matrix */
	res = mxCreateDoubleMatrix(1, 1, mxREAL);
	*mxGetPr(res) = r;
	return res;
}

/**
* Distance of a set of vectors to a single vector.
*/
mxArray* distmatvec(const mxArray* mat, const mxArray* vec) {
	const double* pmat = mxGetPr(mat);
	const double* pvec = mxGetPr(vec);
	
	int m = mxGetM(mat);
	int n = mxGetN(mat);
	int N = mxGetNumberOfElements(vec);
	
	mxArray* res;
	double* pr;

	int i,j;

	if (n != N) {
		mexErrMsgIdAndTxt(__DIMENSIONMISMATCH__, "Input argument matrix should have as many columns as input argument vector.");
	}

	res = mxCreateDoubleMatrix(m, 1, mxREAL);
	pr =  mxGetPr(res);

	/* Z = bsxfun(@minus, X, y); d = sum(Z.^2, 2); */
	for (i = 0; i < m; i++) {
		double* pm = pmat + i;
		double* pv = pvec;
		double r = 0.0;

		for (j = 0; j < n; j++) {
			double d = *pm - *pv;

			pm += m;  /* element in same row, next column in matrix X */
			pv++;     /* next element in vector y */
			r += d*d;
		}
		*(pr++) = r;
	}
	return res;
}

/**
* Pairwise distance of two sets of vectors.
*/
mxArray* distmatmat(const mxArray* mat1, const mxArray* mat2) {
	const double* pmat1 = mxGetPr(mat1);
	const double* pmat2 = mxGetPr(mat2);
	
	int m1 = mxGetM(mat1);
	int n1 = mxGetN(mat1);
	int m2 = mxGetM(mat2);
	int n2 = mxGetN(mat2);
	
	mxArray* res;
	double* pr;

	int i,j;

	if (m1 != m2 || n1 != n2) {
		mexErrMsgIdAndTxt(__DIMENSIONMISMATCH__, "Inconsistent input argument dimensions.");
	}

	res = mxCreateDoubleMatrix(m1, 1, mxREAL);
	pr =  mxGetPr(res);

	for (i = 0; i < m1; i++) {
		double* p1 = pmat1 + i;
		double* p2 = pmat2 + i;
		double r = 0.0;

		for (j = 0; j < n1; j++) {
			double d = *p1 - *p2;

			p1 += m1;
			p2 += m1;
			r += d*d;
		}
		*(pr++) = r;
	}
	return res;
}

/**
* Entry point.
*/
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
	/* check for proper number of input and output arguments */
	nargineqchk(nrhs, 2);
	nargoutltechk(nlhs, 1);

	/* check 1st input argument */
	argdoublechk(prhs, 0);
	argrealchk(prhs, 0);
	argnonemptychk(prhs, 0);

	/* check 2nd input argument */
	argdoublechk(prhs, 1);
	argrealchk(prhs, 1);
	argnonemptychk(prhs, 1);

	if (isvector(prhs[0]) && isvector(prhs[1])) {
		plhs[0] = distvecvec(prhs[0], prhs[1]);
	} else if (isvector(prhs[1])) {
		plhs[0] = distmatvec(prhs[0], prhs[1]);
	} else if (isvector(prhs[0])) {
		plhs[0] = distmatvec(prhs[1], prhs[0]);
	} else {
		plhs[0] = distmatmat(prhs[0], prhs[1]);
	}
}