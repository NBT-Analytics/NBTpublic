function dist = get_distance(obj, idx)

import misc.euclidean_dist;

cart = obj.Cartesian;

dist = euclidean_dist(cart(idx,:), cart);

end