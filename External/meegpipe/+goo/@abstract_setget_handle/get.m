function value = get(obj, varargin)

import exceptions.*;

if nargin < 2,
    
    warning('off', 'MATLAB:structOnObject');
    value = [];
    fNames = fieldnames(obj);    
    for i = 1:numel(fNames)
        value.(fNames{i}) = obj.(fNames{i});
    end
    warning('on', 'MATLAB:structOnObject');
    return;
    
end

%% Take care of first object
value = cell(numel(varargin),1);
for i = 1:numel(varargin)    
    % Don't do any error checking for speed!
    try
    value{i} = obj(1).(varargin{i});    
    catch ME
        % But translate the error into something more readable
        if strcmp(ME.identifier, 'MATLAB:mustBeFieldName'),
            throw(InvalidProp(varargin{i}));
        else
            rethrow(ME);
        end
    end
end

if numel(obj) < 2,
    if numel(value) == 1,
        value = value{1};
    end
    
    return;
end


%% Take care of arrays
if numel(obj) > 1,
    
    % Only single property get is allowed for arrays
    if numel(varargin) > 1,
        error('abstract_get:NotAllowed', ...
            'Only single property get() is allowed for arrays of objects');
    end
    
    propName = varargin{1};
    
    if numel(value) == 1 && ~isempty(value{1}) && isnumeric(value{1}),
        % Fast get for a numeric property of multiple events
        value = nan(size(obj));
        for i = 1:numel(obj),
            thisVal = obj(i).(propName);
            if ~isempty(thisVal),  value(i) = thisVal; end
        end
    else
        % Slow get, returns a cell array of cell arrays
        value = cell(size(obj));
        for i = 1:numel(obj)
            value{i} = get(obj(i), varargin{:});
        end
    end
    
end

if numel(value) == 1,
    value = value{1};
end

end

