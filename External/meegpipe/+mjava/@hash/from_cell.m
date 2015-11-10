function obj = from_cell(cArray)
% FROM_CELL - Construction from a cell array
%
% obj = from_cell(cArray)
%
% Where
%
% CARRAY is a cell array with hash keys and hash values.
%
% OBJ is a mjava.hash object
%
% See also: hash, from_struct


obj = mjava.hash;

i = 1;
while i < numel(cArray)
   S.subs = cArray(i);
   S.type = '()';
   obj = subsasgn(obj, S, cArray{i+1}); 
   i = i + 2;
end


end