function obj = transpose(obj)
% .' Transpose
%
%   OBJ.' is the non-conjugate transpose of a pset object
%
% See also: pset.CTRANSPOSE

obj.Transposed = ~obj.Transposed;

end