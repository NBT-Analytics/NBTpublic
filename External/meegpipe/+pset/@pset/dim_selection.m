function idx = dim_selection(obj)


idx = obj.DimSelection;

if isempty(idx),
    idx = 1:obj.NbDims;
end


end