function obj = set_physdim_prefix(obj, prefix)

unit = get_physdim_unit(obj);
newPhysDim = cellfun(@(x,y) strcat(y, x), unit, prefix, ...
    'UniformOutput', false);
obj  = set_physdim(obj, newPhysDim); 


end