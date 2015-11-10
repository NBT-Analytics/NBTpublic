function obj = destroy_mmemmapfile(obj, idx)
% DESTROY_MMEMMAPFILE Destroys the memory map(s) associated with a pset
% object
%
% destroy_mmemmapfile(obj)
%
%
% See also: pset.

if nargin < 2, idx = []; end

if isempty(idx),
    obj.MemoryMap = [];
    obj.MapIndices = [];
else
    for i = 1:numel(idx),
        obj.MemoryMap{idx} = [];
    end
end
