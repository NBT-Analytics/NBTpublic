function [pnt, tri] = source_layer(obj, dist)


% Distance of every cortical vertex to the brain center
nbVert = size(obj.InnerSkull.pnt, 1);
brainCenter = mean(obj.InnerSkull.pnt);
v = obj.InnerSkull.pnt-repmat(brainCenter, nbVert, 1);

r = sqrt(sum(v.^2, 2));
v = v./repmat(r, 1, 3);

pnt = repmat(brainCenter, nbVert, 1) + v.*repmat(r-dist, 1, 3);

tri = obj.InnerSkull.tri;

end