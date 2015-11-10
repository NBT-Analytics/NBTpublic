function [mmap, midx] = mmemmapfile(datafile, n_dims, n_points, ...
    precision, varargin)
% MMEMMAPFILE Creates a multi-memory-map of a file
%
% [mmap, midx] = mmemmapfile(datafile, n_dims, n_points, precision)
%
% [mmap, midx] = mmemmapfile(datafile, n_dims, n_points, precision, ...
%    'key', value, ...)
%
% Where:
%
% DATAFILE is the path name of the file that will be memory mapped
%
% N_DIMS is the dimensionality of the points stored in DATAFILE
%
% N_POINTS is the number of points stored in DATAFILE
%
% PRECISION is the numerical precision of the points stored in DATAFILE
%
% MMAP is a cell array of memmapfile objects that map contiguous regions of
% the file
%
% MIDX is an array with the indices of the starting point of each generated
% memory map
%
%
% Accepted key/value pairs:
%
% MapSize   : Scalar (def: meegpipe.get_config('pset', 'memory_map_size'))
%             Maximum map size in bytes 
%
% Writable  : Logical value (def: meegpipe.get_config('pset', 'writable'))
%             Should the generated memory maps be writable?
%
%
%
% See also: pset.

import misc.process_varargin;
import misc.sizeof;
import pset.globals;

if nargin < 3 || isempty(datafile) || isempty(n_dims) || ...
        isempty(precision),
    ME = MException('make_memmapfile:invalidInput', ...
        'First 3 input arguments are required');
    throw(ME);
end

THIS_OPTIONS = {'mapsize', 'writable'};

mapsize =  meegpipe.get_config('pset', 'memory_map_size');
writable = meegpipe.get_config('pset', 'writable');

eval(process_varargin(THIS_OPTIONS, varargin));

n_bytes = sizeof(precision)*n_dims;
n_points_map = floor(mapsize/n_bytes);
n_maps = ceil(n_points/n_points_map);
offset = 0;
mmap = cell(n_maps,1);
midx = nan(1,n_maps);
for i = 1:n_maps
    this_map_n_points = min(n_points_map, ...
        n_points-round(offset/n_bytes));
    midx(i) = round(offset/n_bytes)+1;
    mmap{i} = memmapfile(datafile,...
        'Format', {precision [n_dims this_map_n_points] 'Data'}, ...
        'Writable', writable, ...
        'Repeat', 1,...
        'Offset', offset);
    offset = offset + this_map_n_points * n_bytes;
end