function r = brain_radius(obj)

import misc.euclidean_dist;

brainCenter = mean(obj.InnerSkull.pnt);

r = mean(euclidean_dist(brainCenter, obj.InnerSkull.pnt)); 

end