function obj = make_mmemmapfile(obj)
% DESTROY_MMEMMAPFILE Re-makes the memory map(s) associated with a pset
% object
%
% obj = make_mmemmapfile(obj)
%
%
%
% See also: pset.

import pset.pset;

mapsize = meegpipe.get_config('pset', 'memory_map_size');

% Number of points stored in the file
fid = fopen(obj.DataFile);
if fid < 0,
    ME = MException('pset:make_mmemmapfile:InvalidFile', ...
        'I could not open file: %s', obj.DataFile);
    throw(ME);
end
   
n_points = pset.get_nb_points(fid, obj.NbDims, obj.Precision);
fclose(fid);

[obj.MemoryMap, obj.MapIndices] = pset.mmemmapfile(obj.DataFile, obj.NbDims, ...
    n_points, obj.Precision, 'MapSize', mapsize,...
    'Writable', obj.Writable);

obj.NbPoints = n_points;
