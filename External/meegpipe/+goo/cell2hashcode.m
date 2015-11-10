function hashCode = cell2hashcode(cArray)

import datahash.DataHash;
import goo.cell2hashcode;

for i = 1:numel(cArray),
    if isa(cArray{i}, 'goo.hashable') || ...
            isa(cArray{i}, 'goo.hashable_handle'),
        cArray{i} = get_hash_code(cArray{i});
    elseif iscell(cArray{i}),
        cArray{i} = cell2hashcode(cArray{i});
    elseif isobject(cArray{i}),       
        cArray{i} = DataHash(struct(cArray{i}));
    else       
        cArray{i} = DataHash(cArray{i});
    end    
end

hashCode = DataHash(cArray);

end