function caller = caller_id(stack)

caller = strrep(stack(end).file, '@', '');
caller = regexprep(caller, '^[^+]+(\+.+).m$', '$1');
if isempty(strfind(caller, '+')),
    caller = stack(end).name;
else
    caller(1) = [];
    caller = regexprep(caller, '[\\/]*\+', ':');
    caller = regexprep(caller, '[\\/]', ':');
end

end