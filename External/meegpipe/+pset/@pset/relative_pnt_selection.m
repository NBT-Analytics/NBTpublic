function idx = relative_pnt_selection(obj)

if isempty(obj.PntSelectionH),
    idx = pnt_selection(obj);
else
    prevPntSel = obj.PntSelectionH{end};
    currPntSel = pnt_selection(obj);
    idx = find(ismember(prevPntSel, currPntSel));
end


end