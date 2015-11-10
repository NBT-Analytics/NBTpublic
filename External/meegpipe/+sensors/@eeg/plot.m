function h = plot(obj, varargin)
% PLOT - Scatter plot of sensor locations
%
% plot(obj)
% plot(obj, 'Labels', true);
%
% Where
%
% OBJ is a sensors.eeg object
%
%
% See also: sensors.eeg

import misc.split_arguments;
import misc.process_arguments;

if ~has_coords(obj),
    h = [];
    % Nothing to plot
    return;
end

cartesian = cartesian_coords(obj);

[args1, varargin] = ...
    split_arguments({'Labels', 'Project2D', 'Visible'}, varargin);

opt.Labels    = false;
opt.Project2D = false;
opt.Visible   = true;
[~, opt] = process_arguments(opt, args1);

if numel(varargin) < 2,
    varargin = {'r', 'filled'};
end

if opt.Visible,
    visible = 'on';
else
    visible = 'off';
end

set(gcf, 'Visible', visible);
h = gcf;
if opt.Project2D,
    if opt.Labels,
        electrodes = 'labels';
    else
        electrodes = 'on';
    end    
    topoplot([], eeglab(obj), 'whitebk', 'on', ...
        'electrodes', electrodes);
    
else
    scatter3(obj.Cartesian(:,1), cartesian(:,2), cartesian(:,3), varargin{:});
    
    axis equal;
    set(gca, 'visible', 'off');
    set(gcf, 'color', 'white');
    
    if opt.Labels,
        text(cartesian(:,1), cartesian(:,2), cartesian(:,3), labels(obj));
    end
end

if opt.Labels,
    fix_label_looks(h);
end

end



function fix_label_looks(h)

% Make the labels smaller
hT = findobj(h, 'type', 'text');
if numel(hT) > 64,
   
    baseFontSize = get(hT(1), 'FontSize');
    for i = 1:numel(hT)
        set(hT(i), 'FontSize', ceil(baseFontSize*0.7));
    end
end

for i = 1:numel(hT)
   set(hT, 'FontWeight', 'bold'); 
end

end