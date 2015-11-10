function count = print_link(obj, target, name)


if nargin < 3 || isempty(name), name = target; end

count = fprintf(obj, '[%s]: %s\n\n', name, target);


end