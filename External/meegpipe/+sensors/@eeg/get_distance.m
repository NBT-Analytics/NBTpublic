function dist = get_distance(obj, idx)

import misc.euclidean_dist;

cart = obj.Cartesian;

if isempty(cart),
    dist = ones(1, obj.NbSensors);
else
    dist = euclidean_dist(cart(idx,:), cart);    
end


end