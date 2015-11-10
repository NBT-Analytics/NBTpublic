function bool = is_string(value)

bool = ischar(value) && (isempty(value) || ...
    isvector(value) && size(value,1) <= size(value,2));

end