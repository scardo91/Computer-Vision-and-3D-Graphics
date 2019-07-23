% Examples for linear algebra functions.

% Copyright 2008-2009 Levente Hunyadi
function example_linalg

c = [1  2  3  4  5];
r = [1  2.5  3.5  4.5  5.5];
T = toeplitz(c,r);  % uses MEX implementation if available

c = [1 2 3 4 5];
r = [5 6 7 8 9];
H = hankel(c,r);    % uses MEX implementation if available

K = kronecker(eye(2,2), 2*T - H);
disp(K);