function [y, firstValid] = valid_path(pathIn)

if ischar(pathIn), 
    pathIn = {pathIn}; 
elseif ~iscell(pathIn),
    error('misc:valid_path:InvalidInput', 'A cell array was expected');
end

y = false(1, numel(pathIn));
for i = 1:numel(pathIn),
    y(i) = exist(pathIn{i}, 'file')>0;
end

idx = find(y(:), 1, 'first');
if ~isempty(idx),
    firstValid = pathIn{idx};
else
    firstValid = [];
end

end