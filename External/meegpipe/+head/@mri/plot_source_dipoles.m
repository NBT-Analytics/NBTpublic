function h = plot_source_dipoles(obj, index, varargin)
% PLOT_SOURCE_DIPOLES - Plot source dipoles
%
% plot_source_dipoles(obj, index)
%
% plot_source_dipoles(obj, index, 'key', value, ...)
%
%
% where
%
% OBJ is a head.mri object
%
% INDEX is a set of source indices or a cell array with source names
%
%
% Accepted (optional) key/value pairs:
%
% momentum  : if not zero, the momentum of each dipole will also be plotted.
%             Defaults to 1. Use higher values to display longer arrows for
%             each dipole
%
% 
% See also: head.mri

import misc.process_arguments;

COLORS = {[0 1 0], [0 0 1], [0.7 0.5 0.1], [0.1 0.5 0.3]};

if isempty(obj.Source) || isempty(index),
    return;
end

opt.momentum    = false;
opt.surface     = false;
opt.linewidth   =2;
opt.sizedata    =70;
opt.time        =[];
opt.exp         =1.5;
opt.color       =[];

[~, opt] = process_arguments(opt, varargin);

if ~isempty(opt.time),
    opt.sizedata = opt.sizedata/4;
end

if ischar(index) || iscell(index),
    index = source_index(obj, index);
end

if numel(opt.momentum)==1 && numel(index)>1,
    opt.momentum = repmat(opt.momentum, numel(index),1);
end

% Plot the brain opt.surface
if opt.surface,
    h = plot(obj, 'opt.surface', 'InnerSkull', 'sensors', false);
    set(h(1), 'facealpha', 0.02);
    set(h(1), 'edgealpha', 0.03);
else
    h = gcf;
end

hold on;

for i = 1:numel(index)
   thisSource = obj.Source(index(i));    
   points = obj.SourceSpace.pnt(thisSource.pnt,:);
   
   if isempty(opt.color),
       if i > numel(COLORS),
           thisColor = rand(1,3);
       else
           thisColor = COLORS{i};
       end
   else
       thisColor = opt.color(min(size(opt.color,1), i),:);
   end

   thisH = scatter3(points(:,1), points(:,2), points(:,3), 'filled');
   if ~isempty(opt.time),
       set(thisH, 'sizedata', opt.sizedata*abs(thisSource.strength.*thisSource.activation(:,opt.time)).^opt.exp);
   else
       set(thisH, 'sizedata', opt.sizedata);
   end
   set(thisH, 'CData', thisColor);
   h = [h thisH]; %#ok<*AGROW>
   if opt.momentum(i)
       hold on;
       m = obj.Source(index(i)).momentum*opt.momentum(i);
      
       if ~isempty(opt.time), 
          m = m.*abs(repmat((thisSource.strength.*thisSource.activation(:,opt.time)),1,3));
       end
       thisH = quiver3(points(:,1), points(:,2), points(:,3), m(:,1), m(:,2), m(:,3),0);
       set(thisH, 'color', thisColor);
       set(thisH, 'linewidth', opt.linewidth);
       set(thisH, 'autoscale', 'off');
       set(thisH, 'autoscalefactor', 1);
       h = [h thisH];
   end
end

axis equal;
set(gca, 'visible', 'off');
set(gcf, 'color', 'white');
end