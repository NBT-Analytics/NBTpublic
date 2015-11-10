function [name, target] = get_ref(obj, index)


if nargin < 2 || isempty(index), index = 1:nb_refs(obj); end

if any(index) > nb_refs(obj) || any(index) < 0,
    error('error');
end

name    = obj.RefNames(index);
target  = obj.RefTargets(index);

if numel(name) == 1,
    name    = name{1};
    target  = target{1};
end



end