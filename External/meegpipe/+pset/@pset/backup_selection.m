function obj = backup_selection(obj)

if isempty(obj.DimSelection) && isempty(obj.PntSelection),
    return;
end    

obj.DimSelectionH = [obj.DimSelectionH; {obj.DimSelection}];
obj.PntSelectionH = [obj.PntSelectionH; {obj.PntSelection}];

end