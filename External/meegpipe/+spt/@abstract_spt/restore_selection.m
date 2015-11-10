function obj = restore_selection(obj)

if isempty(obj.DimSelectionH) && isempty(obj.ComponentSelectionH),
    obj.DimSelection = [];
    obj.ComponentSelection = [];
    return;
end

obj.DimSelection = obj.DimSelectionH{end};
obj.ComponentSelection = obj.ComponentSelectionH{end};

obj.DimSelectionH(end) = [];
obj.ComponentSelectionH(end) = [];


end