function [evArray, idx] = nn_all(evArray1, evArray2, cmp)
% nn_all - Select all nearest neighbor events 
%
% ## Usage synopsis:
%
% [evArray, idx] = nn_all(evArray1, evArray2)
%
% Where
%
% `evArray` is an `event` array of the same dimensions as the `event` array
% `evArray1`. `evArray` contains in its ith position the nearest event to
% the ith event in `evArray1` among those events in `evArray2`.
%
% `idx` is an array with the indices of the events selected from `avArray2`
%
%
% See also: physioset.event

import misc.nn_all;

if nargin < 3, cmp = []; end

sample1 = get_sample(evArray1);

sample2 = get_sample(evArray2);

if ~isempty(cmp),
    idx = nan(1, numel(evArray1));
    for i = 1:numel(evArray1)
        
        tmpIdx = find(cmp(sample1(i),sample2));
   
        if isempty(tmpIdx),
            continue;
        else
            tmpIdx2 = nn_all(sample1(i), sample2(tmpIdx));
            idx(i) = tmpIdx(tmpIdx2);
        end
    end
    
else
    idx = nn_all(sample1(:), sample2(:));
end

evArray = evArray2(idx(~isnan(idx)));

end