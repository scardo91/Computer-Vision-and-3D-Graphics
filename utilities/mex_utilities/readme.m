% Utilities for MEX files
% Copyright 2008-2009 Levente Hunyadi
%
% C utility functions to simplify writing MEX source files and a make 
% command to build them. 
% 
% The package contains a set of C functions and preprocessor macros to 
% simplify writing MEX source files. The routines help check input and 
% output argument count, argument type, dimension and structure in a MEX 
% file. See "common.c" in the subfolder "include" for details. 
% 
% Sample code is included in the subfolder "example" to demonstrate usage. 
% Examples include squared Euclidean distance between two vectors, a 
% vector and a set of vectors, and between two paired sets of vectors; 
% Kronecker tensor product; Hankel and Toeplitz matrix construction; and 
% catenation of a cell array of sparse matrices into a single sparse 
% matrix. 
% 
% The package also features a make utility that recompiles all C (.c) and 
% C++ (.cpp) MEX source files in a directory hierarchy using a common 
% include directory, checking modification date to avoid unnecessary 
% recompilation. 
function readme

help readme