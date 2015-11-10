function h = plot_mesh(vert, tri, varargin)

import misc.process_arguments;

opt.facecolor = [0.3 0.3 0.3];
opt.facealpha = 0.5;
opt.edgecolor = [0 0 0];
opt.edgealpha = 0.1;
opt.surfvalue = [];
if nargin < 2
    opt.plotvertices = true;
else
    opt.plotvertices = false;
end

[~, opt] = process_arguments(opt, varargin);

if nargin < 2,
    tri = [];
end


if isempty(tri),
    dt = DelaunayTri(vert);
    h = tetramesh(dt);
    hold on;   
    scatter3(vert(:,1), vert(:,2), vert(:,3), 'r', '.');
else
    if isempty(opt.surfvalue),
        tr = TriRep(tri, vert(:,1), vert(:,2), vert(:,3));
        h=trimesh(tr);
    else
        surfValue = opt.surfvalue;
        % Convert to cvalues
        C = colormap;
        surfValue = surfValue - min(surfValue);
        
        if max(surfValue) < eps,
            cValue = zeros(size(surfValue));
        else
            surfValue = surfValue./max(surfValue);
            quantValue = linspace(0, 1, size(C,1));
            cValue = nan(size(surfValue));
            for i = 1:numel(cValue),
                cValue(i) = find(quantValue >= surfValue(i), 1);
            end
        end
        
        tr = delaunay(vert(:,1), vert(:,2), vert(:,3));
        h = trimesh(tr, vert(:,1), vert(:,2), vert(:,3), cValue, ...
            'FaceColor', 'interp');
    end
end
if isempty(opt.surfvalue),
    set(h, ...
        'FaceColor', opt.facecolor, ...
        'EdgeColor', opt.edgecolor);
else
    set(h, 'EdgeColor', 'none');
end
set(h, ...
    'FaceAlpha', opt.facealpha, ...
    'EdgeAlpha', opt.edgealpha);
axis equal;
set(gca, 'visible', 'off');
set(gcf, 'color', 'white');

end