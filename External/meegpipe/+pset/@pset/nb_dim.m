function value = nb_dim(obj)

value = obj.NbDims;

if ~isempty(obj.DimMap)
    value = size(obj.DimMap,1);
    return;
else
    
if ~isempty(obj.DimSelection),
    value = numel(obj.DimSelection);
end


    

end

