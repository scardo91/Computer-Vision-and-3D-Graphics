/*===========================================================================*
* kron2.c
* Fast Kronecker product on homogeneous (both real or complex) matrices.
*
* Copyright 2009 Levente Hunyadi
* All rights reserved.
*===========================================================================*/

#define __PACKAGENAME__ "math:kron"
#include "common.c"

bool is_diagonal(const double* A, int m, int n) {
	int i,j;

	for (j = 0; j < n; j++) {
		for (i = 0; i < m; i++) {
			if (i != j && isnonzero(A[j*m+i])) {
				return false;
			}
		}
	}
	return true;
}

/** Kronecker product of a real A and a real diagonal B. */
void kron_real_diag(const double* A, int ma, int na, const double* B, int mb, int nb, double* C) {
	int i,j,k,l;
	const double* pa;
	double a,b;

	for (j = 0; j < na; j++) {  /* iterate over columns of A */
		for (l = 0; l < nb; l++) {  /* iterative over columns of B */
			pa = &A[j*ma];
			for (i = 0; i < ma; i++) {  /* iterate over rows of A */
				a = (*pa++);
				if (!isnonzero(a)) {  /* no need to multiply by zero */
					C += mb;
					continue;
				}
				
				if (l < mb) {  /* at least i many rows exist in B */
					C += l;  /* skip rows of B in column that are zero */
					b = B[l*mb+l];  /* only nonzero element in column of B */
					*(C++) = a * b;
					C += (mb-l-1);  /* skip remaining rows of B in column that are zero */
				} else {
					C += mb;
				}
			}
		}
	}
}

/** Kronecker product of a real A and a real B. */
void kron_real(const double* A, int ma, int na, const double* B, int mb, int nb, double* C) {
	int i,j,k,l;
	const double* pa;
	const double* pb;
	double a,b;

	for (j = 0; j < na; j++) {  /* iterate over columns of A */
		for (l = 0; l < nb; l++) {  /* iterative over columns of B */
			pa = &A[j*ma];
			for (i = 0; i < ma; i++) {  /* iterate over rows of A */
				a = (*pa++);
				if (!isnonzero(a)) {  /* no need to multiply by zero */
					C += mb;
					continue;
				}
				pb = &B[l*mb];  /* position to lth column of B */
				for (k = 0; k < mb; k++) {  /* iterate over rows of B */
					b = *(pb++);
					*(C++) = a * b;
				}
			}
		}
	}
}

void kron_complex(const double* Ar, const double* Ai, int ma, int na, const double* Br, const double* Bi, int mb, int nb, double* Cr, double* Ci) {
	int i,j,k,l;

	for (j = 0; j < na; j++) {  /* iterate over columns of A */
		for (l = 0; l < nb; l++) {  /* iterative over columns of B */
			const double* par = &Ar[j*ma];
			const double* pac = &Ai[j*ma];
			for (i = 0; i < ma; i++) {  /* iterate over rows of A */
				double ar = *(par++);
				double ac = *(pac++);
				const double* pbr = &Br[l*mb];  /* position to lth column of B */
				const double* pbc = &Bi[l*mb];
				for (k = 0; k < mb; k++) {  /* iterate over rows of B */
					double br = *(pbr++);
					double bc = *(pbc++);

					*(Cr++) = ar * br - ac * bc;  /* multiply complex numbers */
					*(Ci++) = ar * bc + ac * br;
				}
			}
		}
	}
}

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
	int ma, na, mb, nb;

	/* check for proper number of input and output arguments */
	nargineqchk(nrhs, 2);
	nargoutltechk(nlhs, 1);

	/* check that parameters are 2d double real matrices */
	argdoublechk(prhs, 0);
	arg2dchk(prhs, 0);
	argnonemptychk(prhs, 0);

	argdoublechk(prhs, 1);
	arg2dchk(prhs, 1);
	argnonemptychk(prhs, 1);

	ma = mxGetM(prhs[0]);
	na = mxGetN(prhs[0]);
	mb = mxGetM(prhs[1]);
	nb = mxGetN(prhs[1]);

	if (!mxIsComplex(prhs[0]) && !mxIsComplex(prhs[1])) {
		const double* A = mxGetPr(prhs[0]);
		const double* B = mxGetPr(prhs[1]);
		double* C;
		
		plhs[0] = mxCreateDoubleMatrix(ma*mb, na*nb, mxREAL);
		C = mxGetPr(plhs[0]);
		if (is_diagonal(B, mb, nb)) {
			kron_real_diag(A, ma, na, B, mb, nb, C);
		} else {		
			kron_real(A, ma, na, B, mb, nb, C);
		}
	} else if (mxIsComplex(prhs[0]) && mxIsComplex(prhs[1])) {
		const double* Ar = mxGetPr(prhs[0]);
		const double* Ai = mxGetPi(prhs[0]);
		const double* Br = mxGetPr(prhs[1]);
		const double* Bi = mxGetPi(prhs[1]);
		double* Cr;
		double* Ci;

		plhs[0] = mxCreateDoubleMatrix(ma*mb, na*nb, mxCOMPLEX);
		Cr = mxGetPr(plhs[0]);
		Ci = mxGetPi(plhs[0]);
		kron_complex(Ar, Ai, ma, na, Br, Bi, mb, nb, Cr, Ci);
	} else {
		mexErrMsgIdAndTxt(__INVALIDVALUE__, "Operation supported only on exclusively real or exclusively complex operands.");
	}
}