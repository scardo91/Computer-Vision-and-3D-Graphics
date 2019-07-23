% Examples for pairwise squared Euclidean distance.

% Copyright 2008-2009 Levente Hunyadi
function example_sqdist2()

A = [1,2,3,4;1,2,3,4];   % dimensions = vector count times vector dimension
B = [1,2,3,4;5,6,7,8];
a = [1,2,3,4];
b = [5,6,7,8];

fprintf('Euclidean distance of two vectors:\n');
fprintf('sqdist2 =\n');
disp(sqdist2(a,b));
fprintf('built-in MatLab =\n');
disp(norm(a-b)^2);

fprintf('Euclidean distance of a vector from a set of vectors:\n');
fprintf('sqdist2 =\n');
disp(sqdist2(A,b));
fprintf('built-in MatLab =\n');
d = sum(bsxfun(@minus, A, b).^2, 2);
disp(d);

R = rand(10000,128);
s = rand(1,128);
fprintf('sqdist2          ');
tic
sqdist2(R,s);
toc
fprintf('built-in MatLab  ');
tic
sum(bsxfun(@minus, R, s).^2,2);
toc
fprintf('\n');

fprintf('Pairwise Euclidean distance of two sets of vectors:\n');
fprintf('sqdist2 =\n');
disp(sqdist2(A,B));
fprintf('built-in MatLab =\n');
disp(sum((A-B).^2,2));

S = rand(10000,128);
fprintf('sqdist2          ');
tic
sqdist2(R,S);
toc
fprintf('built-in MatLab  ');
tic
sum((R-S).^2,2);
toc
