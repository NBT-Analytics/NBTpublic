function [idx, dist] = nn_radius(a, b, r)

import misc.euclidean_dist;

if size(a,1) > 1, 
    error('This is an error'); 
end


dist = euclidean_dist(a, b);

idx = find(dist < r);

dist = dist(idx);




end