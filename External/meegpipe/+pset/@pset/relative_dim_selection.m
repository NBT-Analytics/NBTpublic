function idx = relative_dim_selection(obj)

if isempty(obj.DimSelectionH),
    idx = dim_selection(obj);
else
    prevDimSel = obj.DimSelectionH{end};
    currDimSel = dim_selection(obj);
    idx = find(ismember(prevDimSel, currDimSel));
end


end