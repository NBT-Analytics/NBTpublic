function hashCode = get_hash_code(obj)
% GET_HASH_CODE - Get MD5 digest from object
%
% hashCode = get_hash_code(obj)
%
% 

import datahash.DataHash;
import goo.pkgisa;
import goo.cell2hashcode;

info = [];

[~, fNames] = fieldnames(obj);

for i = 1:numel(fNames),
    if pkgisa(obj.(fNames{i}), {'goo.hashable', 'goo.hashable_handle'}),
        info.(fNames{i}) = get_hash_code(obj.(fNames{i}));
    elseif iscell(obj.(fNames{i})),
        info.(fNames{i}) = cell2hashcode(obj.(fNames{i}));
    elseif isobject(obj.(fNames{i})),
        warning('off', 'MATLAB:structOnObject');
        warning('off', 'JSimon:BadDataType');
        info.(fNames{i}) = DataHash(struct(obj.(fNames{i})));
        warning('on',  'JSimon:BadDataType');
        warning('on', 'MATLAB:structOnObject');
    else
        warning('off', 'JSimon:BadDataType');
        info.(fNames{i}) = DataHash(obj.(fNames{i}));
        warning('off', 'JSimon:BadDataType');
    end    
end

hashCode = DataHash(info);


end
