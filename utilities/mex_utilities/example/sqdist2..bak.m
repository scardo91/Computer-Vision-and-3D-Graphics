% Squared Euclidean distance.
%
% Input arguments:
% x:
%    a vector or a set of row vectors arranged into a matrix
% y:
%    a vector or a set of row vectors arranged into a matrix
%
% Output arguments:
% d:
%    a scalar or a column vector of Euclidean distances
%
% Examples:
%    A = [1,2,3,4;1,2,3,4];
%    B = [1,2,3,4;5,6,7,8];
%    a = [1,2,3,4];
%    b = [5,6,7,8];
%    sqdist2(a,b)  % Euclidean distance of two vectors
%    sqdist2(A,B)  % pairwise distance of vectors in matrices
%    sqdist2(A,b)  % distance of vector from vectors in matrix

% Copyright 2008-2009 Levente Hunyadi

% This function is implemented as a MEX file.