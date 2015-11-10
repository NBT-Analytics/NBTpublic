function h = plot_inverse_solution_dipoles(obj, varargin)
% PLOT_INVERSE_SOLUTION_DIPOLES - Plots the strength of the inverse solution at each source voxel
%
% plot_inverse_solution_dipoles(obj)
%
% plot_inverse_solution_dipoles(obj, 'key', value, ...)
%
%
% where
%
% OBJ is a head.mri object
%
%
% Common key/value pairs:
%
% 'Time'        : A scalar that specifies the time instant that should be
%                 considered. Use time=1 if the scalp potentials do not
%                 have any temporal variation. Default: 1
%
% 'Momentum'    : A scalar that modifies the length of the plotted dipole
%                 momemtums. If not provided, the momemtums will not be
%                 plotted
%
% 'SizeData'    : A scalar that modifies the size of the voxel markers. Use
%                 higher values to linearly increase the size of each
%                 marker.
%
% 'Exp'         : A scalar that specifies the exponent that should be
%                 applied to the source activation in order to determine
%                 marker size. Use higher values to highlight stronger
%                 source activations. Default: 2
%
% 'SourceIndex' :
%
%
% Less common key/value pairs:
%
% 'surface'     : A boolean determining whether the brain surface should be
%                 plotted. Default: true
%
% 'linwidth'    : A scalar that modifies the thickness of the dipole
%                 momemtum lines. Default: 2
%
%
% See also: head.mri

import misc.process_varargin;

keySet = {'momentum', 'surface', 'linewidth','sizedata','time','exp', ...
    'linewidth', 'threshold', 'sourceindex'};
momentum = brain_radius(obj);
surface = false;
sizedata=100;
exp=2;
time=[];
linewidth  =3; %#ok<*NASGU>
threshold = 1e-6;
sourceindex = numel(obj.InverseSolution); % plot the last solution by default

eval(process_varargin(keySet, varargin));

% Plot the brain surface
if surface,
    h = plot(obj, 'surface', 'InnerSkull', 'sensors', false); %#ok<*UNRCH>
    set(h(1), 'facealpha', 0.02);
    set(h(1), 'edgealpha', 0.03);
else
    h = gcf;
end

hold on;

thisSource = obj.InverseSolution(sourceindex);
points = obj.SourceSpace.pnt(thisSource.pnt,:);

% Only plot points with non-negligible strength
negligible = thisSource.strength < threshold*max(thisSource.strength);
points     = points(~negligible, :);
strength   = thisSource.strength(~negligible);
activation = thisSource.activation(~negligible, :);
thisSource.momentum = thisSource.momentum(~negligible, :);

thisH = scatter3(points(:,1), points(:,2), points(:,3), 'filled');
if ~isempty(time),
    act = abs(strength.*activation(:,time)).^exp;
    act = act./max(abs(act));
    act(act<eps) = 0.000001*max(abs(act));
    set(thisH, 'SizeData', sizedata*abs(act));
else
    set(thisH, 'SizeData', sizedata);
end
set(thisH, 'CData', [1 0 0]);
h = [h thisH]; %#ok<*AGROW>

if momentum > 0
    hold on;
    m = thisSource.momentum/norm(thisSource.momentum);
    m = momentum.*m;
    
    if ~isempty(time),
        m = m.*abs(repmat(act,1,3));
    end
    thisH = quiver3(points(:,1), points(:,2), points(:,3), m(:,1), m(:,2), m(:,3),0);
    set(thisH, 'color', [1 0 0]);
    set(thisH, 'linewidth', linewidth);
    set(thisH, 'autoscale', 'off');
    set(thisH, 'autoscalefactor', 1);
    h = [h thisH];
end
axis equal;
set(gca, 'visible', 'off');
set(gcf, 'color', 'white');

end