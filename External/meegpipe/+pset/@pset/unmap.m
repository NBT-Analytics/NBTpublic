function unmap(obj)
% unmap() - Releases the portion of the VAS ocupied by a pset object
%
% Usage:
%   >> unmap(X)
%
% Inputs:
%   X   - A pset.pset object
%
% Outcome:
%   The portion of the VAS ocupied by the input pset object has been
%   freed. If data from the pset object is accessed after running unmap()
%   the future, the corresponding memory map will be automatically
%   reconstructed.
%
%
% See also: pset.pset

import pset.globals;
import misc.sizeof;

n_bytes = obj.NbDims*sizeof(obj.Precision);

n_points_map = floor(globals.evaluate.MapSize/n_bytes);
n_maps = ceil(obj.NbPoints/n_points_map);
offset = 0;
obj.MemoryMap = cell(n_maps,1);
obj.MapIndices = nan(1,n_maps);
for i = 1:n_maps
    this_map_n_points = min(n_points_map, obj.NbPoints-round(offset/n_bytes));
    obj.MapIndices(i) = round(offset/n_bytes)+1;
    obj.MemoryMap{i} = memmapfile(obj.DataFile,...
        'Format', {obj.Precision [obj.NbDims this_map_n_points] 'Data'},...
        'Writable', obj.Writable,...
        'Repeat', 1,...
        'Offset', offset);
    offset = offset + this_map_n_points * n_bytes;
    
end





end