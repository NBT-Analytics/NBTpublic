function hs = get_hash_code(obj)

tmpHash = mjava.hash;

% IMPORTANT: do not use get_config() here. It will slow down everything to
% a standstill for very long and complex pipelines ...
tmpHash('Config')       = get_hash_code(get_config_reference(obj));
tmpHash('DataSelector') = struct(obj.DataSelector);

hs = get_hash_code(tmpHash);

end
