function index = source_index(obj, str)

InvalidIndex = MException('head:mri:source_index:InvalidIndex', ...
    'A number or a string was expected as second input argument');

if isnumeric(str),
    index = str;
    return;
end

if ~ischar(str),
    throw(InvalidIndex);
end

if strcmpi(str, 'all'),
    index = 1:obj.NbSources;
    return;
end

%index = intersect(index, 1:obj.NbSources);

picked = false(1, obj.NbSources);
for i = 1:obj.NbSources
    if ischar(str) && strcmpi(obj.Source(i).name, str),
        picked(i) = true;
    elseif iscell(str) && ismember(obj.Source(i).name, str),
        picked(i) = true;
    end
end

index = 1:obj.NbSources;
index = index(picked);



end