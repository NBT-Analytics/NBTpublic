function hashCode = get_id(obj)
% GET_ID - Pipeline ID code (6 characters)

if ~isempty(obj.FakeID),
    hashCode = obj.FakeID;
    return;
end

import datahash.DataHash;

hashCode1 = get_static_hash_code(obj);

% Get also a hash code for the version of meegpipe
vers = meegpipe.version;  
hashCode2 = DataHash(vers(1:min(numel(ver), 6)));

hashCode = DataHash({hashCode1, hashCode2});

hashCode = hashCode(end-5:end);

end