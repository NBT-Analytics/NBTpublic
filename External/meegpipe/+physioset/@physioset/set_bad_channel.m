function obj = set_bad_channel(obj, index)
% SET_BAD_CHANNEL - Marks one or more channel(s) as bad
%
%
% obj = set_bad_channel(obj, idx)
%
% Where
%
% OBJ is a physioset.object
%
% IDX is the index or indices of the channels that are to be marked as bad
%
%
% See also: clear_bad_channel, set_bad_sample, physioset

import misc.isnatural;
import physioset.physioset;
import exceptions.BadSubscript;

if nargin < 2 || isempty(index), index = []; end

if islogical(index), index = find(index); end

if ischar(index),
    if strcmpi(index, 'all'),
        index = 1:obj.NbDims;
    elseif strcmpi(index, 'none'),
        index = [];
    else
        physioset.InvalidChannelIndex(['Unknown channel index ''' ...
            index(:)' '''']);
    end
end

if ~isempty(index) && ~isnatural(index),
    throw(BadSubscript('Channel index must be a natural number'));
end

if any(index > obj.NbDims),
    throw(BadSubscript(...
        sprintf('Channel index (%d) exceeds number of channels (%d)', ...
        find(index>obj.NbDims, 1), obj.NbDims)));
end

if isempty(obj.DimSelection),
    obj.BadChan(index) = true;
else
    obj.BadChan(obj.DimSelection(index)) = true;
end


end