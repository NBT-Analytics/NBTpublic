function hs = get_static_hash_code(obj)

tmpHash = mjava.hash;

tmpHash('Name')         = obj.Name;
tmpHash('Config')       = get_hash_code(get_config(obj));
tmpHash('DataSelector') = struct(obj.DataSelector);


if ~isempty(obj.Static_),
    tmpHash('Static_')  = get_hash_code(obj.Static_);
end

% We do not take into account Parent_ and NodeIndex_. The hash code should
% identify only local node changes.

hs = get_hash_code(tmpHash);


end