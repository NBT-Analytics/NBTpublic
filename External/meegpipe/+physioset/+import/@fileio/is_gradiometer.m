function isGrad = is_gradiometer(unitArray)

REGEX = '.+/.?m$';
isGrad = cellfun(@(x) ~isempty(x), regexp(unitArray, REGEX)); 


end