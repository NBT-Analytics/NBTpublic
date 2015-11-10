function count = print_ref(obj, target, name)

if nargin < 3 || isempty(name), name = target; end

count = fprintf(obj, '[%s]: [[Ref: %s]]\n\n', name, target);


end