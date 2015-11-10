function obj = make_source_grid(obj, density)
% MAKE_SOURCE_GRID - Creates a 3D grid of candidate source locations
%
% obj = make_source_grid(obj, density)
%
% where
%
% OBJ is a head.mri object
%
% DENSITY is a scalar argument in the rage [0 1] determining the density of
% the generated grid. If density=0 the grid will be maximally coarse and if
% density=1 it will be maximally dense. Default: density=0.5
%
%
% See also: head.mri

import fieldtrip.bounding_mesh;

% Maximum number of voxels per axis
MAX_NB_VOXELS = 30; 

InvalidDensity = MException('head:mri:make_source_grid', ...
    'Invalid grid density');


if nargin < 2 || isempty(density),
    density = 0.5;
end

if numel(density) ~= 1 || ~isnumeric(density) || density < 0 || density > 1,
    throw(InvalidDensity);
end

% Generate a source grid
minValues   = ceil(min(obj.InnerSkull.pnt));
maxValues   = floor(max(obj.InnerSkull.pnt));
maxNbVoxels = MAX_NB_VOXELS;
nbVoxels = max(3, ceil(density*maxNbVoxels));
xv = linspace(1.1*minValues(1), .9*maxValues(1), nbVoxels);
yv = linspace(1.1*minValues(2), .9*maxValues(2), nbVoxels);
zv = linspace(1.1*minValues(3), .9*maxValues(3), nbVoxels);
[X,Y,Z] = meshgrid(xv,yv,zv);
obj.SourceSpace.pnt = [X(:) Y(:) Z(:)];

% Plot the grid
figure;
h = plot(obj, 'surface', 'InnerSkull', 'sensors', false, 'sourcespace', true);
set(h(1), 'facealpha', 1);
set(h(1), 'edgealpha', 0);
set(gcf, 'Name', '3D grid of source dipoles');

% Determine which points are inside and which points are outside
obj.DelaunayTess = delaunayn(obj.InnerSkull.pnt);
t = tsearchn(obj.InnerSkull.pnt, obj.DelaunayTess, ...
    obj.SourceSpace.pnt);
obj.SourceSpace.pnt = obj.SourceSpace.pnt(~isnan(t), :);

% Use also Fieldtrip algorithm (none of the two is perfect for non-convex
% surfaces)
inside = bounding_mesh(obj.SourceSpace.pnt, ...
    obj.InnerSkull.pnt, obj.InnerSkull.tri);
obj.SourceSpace.pnt(~inside,:) = [];
obj.SourceSpace.depth = head.mri.point_depth(obj.InnerSkull.pnt, ...
    obj.SourceSpace.pnt);

% Plot the inside locations
figure;
h  = plot(obj, 'surface', 'InnerSkull', 'sensors', false, 'sourcespace', true);
set(h(1), 'facealpha', 0);
set(gcf, 'Name', 'Dipoles inside the inner skull');

obj.Source = [];
obj.FieldTripVolume = [];
obj.LeadField = [];
end