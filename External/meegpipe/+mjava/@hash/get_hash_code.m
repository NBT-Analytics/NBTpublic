function code = get_hash_code(obj)
% GET_HASH - Get MD5 hash from mjava.hash object
%
% code = get_hash(obj)
%
% Where
%
% CODE is a 32-char MD5 digest of object OBJ.
%
% See also: mjava.hash


import datahash.DataHash;

hashKeys = sort(keys(obj));

S.type = '()';
S.subs = {hashKeys};
hashVals = subsref(obj, S);
if numel(hashKeys) < 2
    hashVals = {hashVals};
end

for i = 1:numel(hashVals)
    
    if isa(hashVals{i}, 'mjava.hash'),
        
        
        hashVals{i} = get_hash_code(hashVals{i});
        
    else
        
        hashVals{i} = DataHash(hashVals{i});
        
    end
    
end

code = DataHash([hashKeys, hashVals]);