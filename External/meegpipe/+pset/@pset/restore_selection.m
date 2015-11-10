function obj = restore_selection(obj)

if isempty(obj.DimSelectionH),
    obj.DimSelection = [];
    obj.PntSelection = [];
    return;
end

obj.DimSelection = obj.DimSelectionH{end};
obj.PntSelection = obj.PntSelectionH{end};

obj.DimSelectionH(end) = [];
obj.PntSelectionH(end) = [];

end