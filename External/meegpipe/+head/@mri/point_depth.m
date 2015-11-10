function value = point_depth(surfPoints, point)
% POINT_DEPTH - Depth of a point within a surface

import misc.euclidean_dist;

if size(point,1) > 1, 
    value = nan(size(point,1),1);
    for i = 1:size(point,1),
        value(i) = head.mri.point_depth(surfPoints, point(i,:));
    end
    return;
end

cmass       = mean(surfPoints);
nVert       = size(surfPoints,1);
surfPoints  = surfPoints - repmat(cmass, nVert,1);
point       = point-cmass;

distSurf = euclidean_dist(surfPoints, [0 0 0]);
nSurf    = surfPoints./repmat(distSurf, 1, 3);
spIndex = find_surface_point(nSurf, point/norm(point)); 
value = euclidean_dist(surfPoints(spIndex,:), point);

end

function index = find_surface_point(nSurf, nPoint)

dot = nSurf*nPoint';
[~, index] = max(dot);

end