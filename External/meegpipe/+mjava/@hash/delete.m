function obj = delete(obj, key)
% DELETE - Deletes one or more keys from a hash
%
%
% obj = delete(obj, key)
%
%
% Where
%
% OBJ is a hash object
%
% KEY is a key (a string) or a cell array of keys (a cell array of strings)
%
%
% See also: hash

if iscell(key),
    for i = 1:numel(key),
        obj = delete(obj, key{i});
    end
    return;
end

if ~ischar(key),
    InvalidKey = MException('','');
    throw(InvalidKey);
end

obj.Hashtable.remove(key);


end