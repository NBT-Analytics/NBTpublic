function [setNames, getNames] = fieldnames(x)
% FIELDNAMES - Class property names
%
% [setNames, getNames] = fieldnames(x)
%
% Where:
%
% SETNAMES is a cell array of setable property names
%
% GETNAMES is a cell array of getable property names
%
%
% See also: setget

mco = metaclass(x);
getNames = {};
setNames = {};

for i = 1:length(mco.Properties)
    all_names{i} = mco.Properties{i}.Name;
    if strcmpi(mco.Properties{i}.GetAccess, 'public'),
        getNames = [getNames {mco.Properties{i}.Name}];        %#ok<*AGROW>
    end
    if ~mco.Properties{i}.Dependent && ...
            strcmpi(mco.Properties{i}.SetAccess, 'public'),
        setNames = [setNames {mco.Properties{i}.Name}];
    end
end

end