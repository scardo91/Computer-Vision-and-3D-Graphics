/*===========================================================================*
* cell2sparse.c
* Convert cell array of sparse matrices to single sparse matrix.
*
* Copyright 2008 Levente Hunyadi
* All rights reserved.
*===========================================================================*/

/* Compile this code with
 *
 *    mex cell2sparse.c
 *    mex -g cell2sparse.c      (for debug symbols)
 *
 * If you are using a compiler that equates NaN to be zero, you must compile
 * this example using the flag -DNAN_EQUALS_ZERO. For example:
 *
 *    mex -DNAN_EQUALS_ZERO cell2sparse.c
 *
 * This will correctly define the isnonzero macro for your C compiler.
 */

#define __PACKAGENAME__ "math:cell2sparse"
#include "common.c"

mxArray* cellsubsref(const mxArray* cellarr, mwSize i, mwSize j) {
	mwIndex subs[2] = { i, j };
	mwIndex	ix = mxCalcSingleSubscript(cellarr, 2, &subs);
	return mxGetCell(cellarr, ix);
}

/* Verify shape consistency for cell array of matrices. */
bool isshapeconsistent(const mxArray* cellarr, mwSize cm, mwSize cn, const mwSize *rowcounts, const mwSize *colcounts) {
	mwSize ci, cj;  /* variables to iterate over dimensions of cell array */
	mwIndex ix = 0;  /* index to iterate over cells of cell array in linear manner */

	for (cj = 0; cj < cn; cj++) {
		for (ci = 0; ci < cm; ci++) {
			const mxArray* cell = mxGetCell(cellarr, ix++);
			mwSize m = mxGetM(cell);
			mwSize n = mxGetN(cell);

			if (m != rowcounts[ci] || n != colcounts[cj]) {
				return false;
			}
		}
	}
	return true;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
	const mxArray* cellarr;
	mwSize cm, cn;  /* dimensions of cell array */
	mwSize ci, cj;  /* variables to iterate over dimensions of cell array */
	mwSize m, n;  /* dimensions of array within each cell */
	mwSize i, j;  /* variables to iterate over dimensions of matrices encapsulated in cells */
	mwSize *rowcounts, *colcounts;  /* row and column count of matrices encapsulated in cells */
	mwSize *rowoffsets;
	int cmplx;  /* whether the concatenated large matrix is complex */
	double *sr, *si;
	mwIndex* irs, *jcs;
	mwSize k;

    /* check for proper number of input and output arguments */
	nargineqchk(nrhs, 1);
	nargoutltechk(nlhs, 1);

	/* check data type of input arguments */
	arg2dchk(prhs, 0);
	argnonemptychk(prhs, 0);
    if ( !mxIsCell(prhs[0]) ) {
		mexErrMsgIdAndTxt(__ARGTYPEMISMATCH__, "Input argument must be of type cell.");
	}
	cellarr = prhs[0];

	/* get cell array dimensions */
	cm = mxGetM(cellarr);
	cn = mxGetN(cellarr);

	/* retrieve sizes of encapsulated matrices */
	colcounts = (mwSize *) mxCalloc(cn, sizeof(mwSize));
	n = 0;
	for (cj = 0; cj < cn; cj++) {
		const mxArray* arr = cellsubsref(cellarr, 0, cj);
		int colcount = mxGetN(arr);

		colcounts[cj] = colcount;
		n += colcount;
	}
	rowcounts = (mwSize *) mxCalloc(cm, sizeof(mwSize));
	rowoffsets = (mwSize *) mxCalloc(cm, sizeof(mwSize));
	m = 0;
	for (ci = 0; ci < cm; ci++) {
		const mxArray* arr = cellsubsref(cellarr, ci, 0);
		int rowcount = mxGetM(arr);

		rowcounts[ci] = rowcount;
		rowoffsets[ci] = m;
		m += rowcount;
	}

	/* verify shape consistency of cells */
	if ( !isshapeconsistent(cellarr, cm, cn, rowcounts, colcounts) ) {
		mexErrMsgIdAndTxt(__DIMENSIONMISMATCH__, "Dimensions of matrices in cells are not consistent.");
	}

    /* allocate space for sparse matrix */
	cmplx = isanycomplex(cellarr);
	plhs[0] = mxCreateSparse(m, n, nonzerocount(cellarr), cmplx);
	sr  = mxGetPr(plhs[0]);
    si  = mxGetPi(plhs[0]);
    irs = mxGetIr(plhs[0]);
    jcs = mxGetJc(plhs[0]);

	k = 0;  /* current offset in row index vector */
	for (cj = 0; cj < cn; cj++) {
		for (j = 0; j < colcounts[cj]; j++) {
			*(jcs++) = k;

			for (ci = 0; ci < cm; ci++) {
				const mxArray *arr = cellsubsref(cellarr, ci, cj);
				mwIndex *jc;
				mwIndex minindex, maxindex;
				mwIndex *ir;
				double *pr, *pi;

				if ( !mxIsSparse(arr) ) {
					mexErrMsgIdAndTxt(__ARGTYPEMISMATCH__, "Cell array elements must be sparse.");
				}
				jc = mxGetJc(arr);
				minindex = jc[j];  /* first row index in column */
				maxindex = jc[j+1];  /* last row index in column */
				ir = mxGetIr(arr) + minindex;  /* row index range of interest */
				pr = mxGetPr(arr);
				pi = mxGetPi(arr);

				for (i = 0; i < maxindex - minindex; i++) {
					*(irs++) = rowoffsets[ci] + *(ir++);  /* copy row index with appropriate offset */
					*(sr++) = *(pr++);
					if (cmplx) {
						if (pi != NULL) {
							*(si++) = *(pi++);
						} else {
							*(si++) = 0.0;
						}
					}
					k++;
				}
			}
		}
	}
	*jcs = k;
}