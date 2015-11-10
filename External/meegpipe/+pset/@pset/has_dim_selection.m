function bool = has_dim_selection(obj)

dimSel = dim_selection(obj);

bool = numel(dimSel) ~= obj.NbDims;

if bool,
    return;
end

allDims = 1:obj.NbDims;

bool = ~all(allDims == dimSel);


end