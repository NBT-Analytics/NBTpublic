function bool = has_selection(obj)


dimSel = dim_selection(obj);
pntSel = pnt_selection(obj);

bool = numel(dimSel) ~= obj.NbDims | numel(pntSel) ~= obj.NbPoints;

if bool,
    return;
end

allPnt  = 1:obj.NbPoints;
allDims = 1:obj.NbDims;

bool = ~all(allPnt == pntSel) | ~all(allDims == dimSel);


end