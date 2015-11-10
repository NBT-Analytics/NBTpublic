function obj = restore_offset(obj)

import misc.eta;

tinit = tic;
for i = 1:size(obj,1)
   
    if ~isempty(obj.DimSelection),
        thisDim = obj.DimSelection(i);
    else
        thisDim = i;
    end    
    obj.PointSet(i, :) = obj.PointSet(i,:) + obj.Offset(thisDim);
    
    if is_verbose(obj),
        eta(tinit, size(obj, 1), i);
    end
    
    
end

end