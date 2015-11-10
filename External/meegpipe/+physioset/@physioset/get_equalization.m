function [w, wO, pD] = get_equalization(obj)

w  =  obj.EqWeights;
wO =  obj.EqWeightsOrig;
pD = obj.PhysDimPrefixOrig;

if isempty(w) || isempty(obj.DimSelection), 
    return; 
end

w  = w(obj.DimSelection, obj.DimSelection);
wO = wO(obj.DimSelection, obj.DimSelection);
pD = pD(obj.DimSelection);




end