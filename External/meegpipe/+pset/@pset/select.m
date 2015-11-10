function obj = select(obj, rowIdx, colIdx, remember)

if nargin < 4, remember = true; end

if nargin < 2, return; end

if remember,
    backup_selection(obj);
end

if nargin == 2 && ischar(rowIdx) && strcmp(rowIdx, 'all'),
    rowIdx = 1:nb_dim(obj);
    colIdx = 1:nb_pnt(obj);   
end

if nargin < 3 || isempty(colIdx), 
    colIdx = 1:nb_pnt(obj); 
end

if isempty(rowIdx),
    rowIdx = 1:nb_dim(obj);
end

if ~isempty(rowIdx) && islogical(rowIdx), rowIdx = find(rowIdx); end
if ~isempty(colIdx) && islogical(colIdx), colIdx = find(colIdx); end

if any(rowIdx > nb_dim(obj)) || any(colIdx > nb_pnt(obj)) || ...
        any(rowIdx < 1) || any(colIdx < 1),
    
    error('Out of range selection');
    
end

if ~isempty(obj.DimSelection),
    rowIdx = obj.DimSelection(rowIdx);
end

if ~isempty(obj.PntSelection),
    colIdx = obj.PntSelection(colIdx);
end

obj.PntSelection = colIdx;
obj.DimSelection = rowIdx;


end