
function obj = set_properties(obj, opt, varargin)

import misc.process_arguments;

[~, opt] = process_arguments(opt, varargin, [], true);
fNames = fieldnames(opt);

for i = 1:numel(fNames)
    obj.(fNames{i}) = opt.(fNames{i});
end

end
