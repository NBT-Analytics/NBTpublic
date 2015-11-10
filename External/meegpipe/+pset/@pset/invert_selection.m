function obj = invert_selection(obj, backup)
% INVERT_SELECTION - Inverts data selection for a pointset

if nargin < 2 || isempty(backup), backup = true; end

if backup,
    backup_selection(obj);
end

obj.PntSelection = setdiff(1:obj.NbPoints, obj.PntSelection);
obj.DimSelection = setdiff(1:obj.NbDims, obj.DimSelection);

end