function obj = backup_projection(obj)

if isempty(obj.DimMap)
    return;
end

obj.DimMapH = [obj.DimMapH; {obj.DimMap}];
obj.DimInvMapH = [obj.DimInvMapH; {obj.DimInvMap}];


end