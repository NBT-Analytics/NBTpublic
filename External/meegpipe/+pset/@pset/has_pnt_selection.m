function bool = has_pnt_selection(obj)

pntSel = pnt_selection(obj);

bool = numel(pntSel) ~= obj.NbPoints;

if bool,
    return;
end

allPnt  = 1:obj.NbPoints;

bool = ~all(allPnt == pntSel);


end