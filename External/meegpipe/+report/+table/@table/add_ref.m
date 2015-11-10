function obj = add_ref(obj, name, target)

if ischar(name), name = {name}; end
if ischar(target), target = {target}; end

if ~iscell(name) || ~iscell(target),
    error('error');
end

if numel(name) ~= numel(target),
    error('error');
end

obj.RefNames   = [ obj.RefNames;     name(:)];
obj.RefTargets = [ obj.RefTargets;   target(:)];



end