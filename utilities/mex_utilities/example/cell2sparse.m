% Convert cell array of sparse matrices to single sparse matrix.
% The contents of the cell must be able to catenate into a hyperrectangle.
% Moreover, for each pair of neighboring cells, the dimensions of the
% cells' contents must match, excluding the dimension in which the cells
% are neighbors.
%
% Input arguments:
% c:
%    a cell array whose cells are sparse matrices
%
% Example:
%    A legal catenation pattern is as follows:
%
%    { 10x25 } { 10x25 }        {             }
%    { 20x25 } { 20x25 }  --->  {    60x50    }
%    { 30x25 } { 30x25 }        {             }
%
% See also: cell2mat

% Copyright 2008-2009 Levente Hunyadi

% This function is implemented as a MEX file.