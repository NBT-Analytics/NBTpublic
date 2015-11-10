function value = is_bad_sample(obj, idx)
% IS_BAD_SAMPLE - Bad sample markings
%
% bool = is_bad_sample(obj, idx)
%
% Where
%
% IDX is one or more sample indices
%
% BOOL is a logical vector of the same size as IDX with true values only
% for those entries corresponding to bad samples.
%
% See also: is_bad_channel, physioset

import misc.isnatural;
import exceptions.*

if nargin < 2 || isempty(idx), idx = 1:nb_pnt(obj); end

if ~isempty(idx) && ~isnatural(idx),
    throw(physioset.InvalidSampleIndex(...
        'Sample index must be a natural number'));
end

if any(idx > nb_pnt(obj)),
    
    throw(physioset.InvalidSampleIndex(...
        sprintf('Sample index (%d) exceeds number of samples (%d)', ...
        find(idx>nb_pnt(obj), 'first'), nb_pnt(obj))));
    
end

if ~isempty(obj.PntSelection),
    idx = obj.PntSelection(idx);
end

value = obj.BadSample(idx);

end