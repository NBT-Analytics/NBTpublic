function bool = has_changed_config(obj)

storedHash = get_static(obj, 'hash', 'config');

if isempty(storedHash),
    bool = true;
else
    currHash = get_hash_code(get_config(obj));
    bool = ~strcmp(currHash, storedHash);
end

end