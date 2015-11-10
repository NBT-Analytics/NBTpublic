function valuesCell = values(obj)
% VALUES - Returns a cell array of hash values
%
% 
% valuesCell = keys(obj)
%
%
% Where
%
% OBJ is a hash object
%
% VALUESCELL is a cell array of hash values
%
%
% See also: hash

objKeys = keys(obj);

if ischar(objKeys), objKeys = {objKeys}; end

valuesCell = cell(size(objKeys));
for i = 1:numel(objKeys),
   sub.type = '()';
   sub.subs = objKeys(i);
   valuesCell{i} = subsref(obj, sub); 
end


end