function out = is_valid_dim(type, dim)

import io.edfplus.signal_types;
import io.edfplus.dimension_prefixes;

if nargin < 2 || isempty(dim) || isempty(type),
    error('Two input arguments were expected');
end
    
if ischar(type), 
    type = {type};
elseif ~iscell(type),
    error('TYPE must be a string or a cell array of strings');
end

if ischar(dim),
    dim = {dim};
elseif ~iscell(dim),
    error('DIM must be a string or a cell array of strings');
end

if numel(type) == 1 && numel(dim) > 1,
    type = repmat(type, numel(dim),1);
elseif numel(dim) == 1 && numel(type) > 1,
    dim = repmat(dim, numel(type), 1);
end


out = strcmpi(type, 'unknown') | strcmpi(dim, 'na');

if all(out), return; end

[~, validDim] = signal_types(type(~out));

isEmpty = cellfun(@(x) isempty(x{1}), validDim);
out(~out) = out(~out) | isEmpty;

if all(out), return; end

prefix = dimension_prefixes;

out(~out) = out(~out) | ...
    cellfun(@(x) is_valid(dim(~out), x, prefix), validDim(~isEmpty));

end



function out = is_valid(dim, validDim, prefix)

out = false;
for i = 1:numel(validDim),
    thisValidDim = validDim{i};
    if ischar(thisValidDim), thisValidDim = {thisValidDim}; end
    if numel(thisValidDim) == 1 && isempty(thisValidDim{1}),
        % No physical dimensions are specified for this signal type
        out = true;
        return;
    end
    for j = 1:numel(thisValidDim),
        [mat, tok] = regexpi(dim, ['(\w?)' thisValidDim{j} '$'], ...
            'match', 'tokens');
        if ~isempty(mat),
            break;
        end
    end
  
    if ~isempty(tok{1}{1}),        
            isValidPrefix = ismember(tok{1}{1}, prefix);
            if isValidPrefix,
                out = true;
                return;
            else
                % No match
                continue;
            end
    else        
        out = true;
        return;
    end   
end

end
