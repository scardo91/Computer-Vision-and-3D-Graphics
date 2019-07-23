% Examples for cell to sparse matrix catenation.

% Copyright 2008-2009 Levente Hunyadi
function example_sparse

aa = speye(10,15);
ab = speye(20,15);
ac = speye(30,15);
ba = speye(10,25);
bb = speye(20,25);
bc = speye(30,25);
c = { aa, ba ; ab, bb ; ac, bc };
s = cell2sparse(c);
spy(s);