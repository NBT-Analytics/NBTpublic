function y = isfloat(pset)
% ISFLOAT True for pset objects.
%
%   ISFLOAT(pset. returns true if pset.is a pset object.
%
% See also: pset.ISA, pset.DOUBLE, pset.SINGLE, pset.ISNUMERIC,
% pset.ISINTEGER

y = isfloat(eval([pset.Precision '(0);']));


end