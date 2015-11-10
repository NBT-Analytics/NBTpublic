function bool = has_changed_runtime(obj)

storedHash = get_static(obj, 'hash', 'runtime');

if isempty(storedHash),
    bool = true;
else
    currHash = get_hash_code(obj.RunTime_);
    bool = ~strcmp(currHash, storedHash);
end



end