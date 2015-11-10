function value = is_bad_channel(obj, index)
% IS_BAD_CHANNEL - Bad channel markings
%
% bool = is_bad_channel(obj, idx)
%
% Where
%
% IDX is one or more channel indices
%
% BOOL is a logical vector of the same size as IDX with true values only in
% those entries corresponding to bad channels.
%
% See also: is_bad_sample, set_bad_channel, physioset

% Documentation: class_physioset.txt
% Description: Bad channel markings

import misc.isnatural;
import physioset.physioset;

if nargin < 2 || isempty(index), index = 1:nb_dim(obj); end

if ~isempty(index) && ~isnatural(index),
    throw(physioset.InvalidChannelIndex(...
        'Channel index must be a natural number'));
end

if any(index > nb_dim(obj)),
    throw(physioset.InvalidChannelIndex(...
        sprintf('Channel index (%d) exceeds number of channels (%d)', ...
        find(index>nb_dim(obj), 'first'), nb_dim(obj))));
end

if ~isempty(obj.DimSelection),
    index = obj.DimSelection(index);
end

value = obj.BadChan(index);

end