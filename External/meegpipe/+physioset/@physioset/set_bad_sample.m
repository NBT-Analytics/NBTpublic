function [obj, evIdx] = set_bad_sample(obj, idx)
% SET_BAD_SAMPLE - Marks one or more sample(s) as bad
%
%
% obj = set_bad_sample(obj, idx)
%
% Where
%
% OBJ is a physioset.object
%
% IDX is the index or indices of the samples that are to be marked as bad
%
%
% See also: clear_bad_sample, set_bad_channel, physioset


import misc.isnatural;
import exceptions.*

if nargin < 2 || isempty(idx), idx = []; end

if islogical(idx), idx = find(idx); end

if ~isempty(idx) && ~isnatural(idx),
    throw(InvalidArgValue('idx', 'Sample index must be a natural number'));
end

if any(idx > nb_pnt(obj)),
    throw(InvalidArgValue('idx', ...
        sprintf('Sample index (%d) exceeds number of samples (%d)', ...
        idx(find(idx(:) > nb_pnt(obj), 1, 'first')), nb_pnt(obj))));
end

if isempty(obj.PntSelection), 
     obj.BadSample(idx) = true;
else
    obj.BadSample(obj.PntSelection(idx)) = true;   
end

% Add 'boundary' events at the onset of each bad data epoch
[obj, evIdx] = add_boundary_events(obj);
    

end