function obj = select(obj, compIdx, dimIdx, backup)


if nargin < 4 || isempty(backup), backup = true; end

if nargin < 3 || isempty(dimIdx), dimIdx = 1:nb_dim(obj); end

if nargin < 2 || isempty(compIdx), compIdx = 1:nb_component(obj); end

if backup,
    obj = backup_selection(obj);
end

if ~isempty(dimIdx) && islogical(dimIdx), dimIdx = find(dimIdx); end
if ~isempty(compIdx) && islogical(compIdx), compIdx = find(compIdx); end

if any(dimIdx > nb_dim(obj)) || any(compIdx > nb_component(obj)) || ...
        any(dimIdx < 1) || any(compIdx < 1),   
    error('Out of range selection');    
end

if ~isempty(obj.DimSelection),
    dimIdx = obj.DimSelection(dimIdx);
end

if ~isempty(obj.ComponentSelection),
    compIdx = obj.ComponentSelection(compIdx);
end

obj.ComponentSelection = compIdx;
obj.DimSelection = dimIdx;

end