function h = plot_inverse_solution_surface(obj, idx, varargin)

import misc.plot_mesh;
import misc.euclidean_dist;
import fieldtrip.projecttri;

if isempty(obj.SourceSpace),
    error('You need to run inverse_solution() first');
end

if ~isfield(obj.SourceSpace, 'pnt_surf_idx'),
    error('Source space is not made of surfaces');
end

if numel(idx) ~= 1,
    error('numel(idx) must be equal to 1');
end

val = obj.InverseSolution.strength(obj.SourceSpace.pnt_surf_idx == idx);

if isempty(val),
    error('There is no surface with index %d', idx);
end

pnt = obj.SourceSpace.pnt(obj.SourceSpace.pnt_surf_idx == idx,:);

tri = projecttri(pnt, 'delaunay');

h = patch('Vertices', pnt, 'Faces', tri, ...
    'FaceVertexCData', val, ...
    'FaceColor', 'interp');
set(h, 'EdgeColor', 'none');
set(h, 'FaceLighting', 'none');

axis off
axis vis3d
axis equal


end