function name = get_name(obj)


fullName = get_full_name(obj);

name = lower(regexprep(fullName, '[^\w]+', '-'));

end