% Kronecker tensor product.
%
% See also: kron

% Copyright 2008-2009 Levente Hunyadi
function K = kronecker(X,Y)

validateattributes(X, {'numeric'}, {'2d'});
validateattributes(Y, {'numeric'}, {'2d'});
if ~issparse(X) && ~issparse(Y) && (isreal(X) && isreal(Y) || ~isreal(X) && ~isreal(Y))
    K = kron2(X,Y);  % efficient MEX implementation
else
    K = kron(X,Y);
end
