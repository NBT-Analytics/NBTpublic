function obj = restore_projection(obj)

if isempty(obj.DimMapH),
    obj.DimMap      = [];
    obj.DimInvMap   = [];
end

obj.DimMap      = obj.DimMapH{end};
obj.DimInvMap   = obj.DimInvMapH{end};

obj.DimMapH(end)    = [];
obj.DimInvMapH(end) = [];

end