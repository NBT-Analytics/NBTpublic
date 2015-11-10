function [idx, dist] = nn_all(a, b, forward)
%
% a source set of points
% b target set of points

import misc.nn_all;

if nargin < 3 || isempty(forward), forward = 0; end

if nargin < 2,
    % nn to every other point, except itself
    idx = nan(size(a,1),1);
    dist = nan(size(a,1),1);
    for i = 1:size(a,1)
        thisidx = setdiff(1:size(a,1), i);
        b = a(thisidx, :);
        [idx(i), dist(i)] = nn_all(a(i,:), b, forward);        
        idx(i) = thisidx(idx(i));
    end
    return    
    
end

import misc.euclidean_dist;

dist = nan(size(a,1),1);
idx = nan(size(a,1),1);
for i = 1:size(a,1)
    if forward > 0
        thisB = b(i:end, :);
        if isempty(thisB), continue; end
        alldist = euclidean_dist(a(i,:), thisB);
    elseif forward < 0
        thisB = b(1:min(size(b,1),i), :);
        if isempty(thisB), continue; end
        alldist = euclidean_dist(a(i,:), thisB);
    else
        alldist = euclidean_dist(a(i,:), b);
    end
    [dist(i), idx(i)] = min(alldist);
end


end