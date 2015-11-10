function set_fvtool_looks(obj)
% SET_FVTOOL_LOOKS - Ensure a consistent look with and without a display
%


set_axes(obj, 'XTickMode', 'manual');
set_axes(obj, 'XTick', linspace(0, 0.9, 10));

set_axes(obj,   'FontSize', 6);
set_xlabel(obj, 'FontSize', 5);
set_ylabel(obj, 'FontSize', 5);
set_title(obj,  'FontSize', 6);

origSelection = obj.Selection;

for i = 1:nb_plots(obj)
    select(obj, i);
    
    yLims   = get_axes(obj, 'YLim');
    yRange  = abs(diff(yLims));
    set_axes(obj, 'YTickMode', 'manual');
    if yRange > 40,
        % This is a magnitude plot
        yTick1 = 10*ceil(yLims(1)/10);
        yTick2 = 10*floor(yLims(2)/10);
        yTicks = yTick1:10:yTick2;
        xFactor = 0.1;
        yFactor = 0.25;
        tFactor = 0.08;
    else
        % This is probably a phase plot
        yTick1 = ceil(yLims(1));
        yTick2 = floor(yLims(2));
        yTicks = yTick1:1:yTick2;       
        xFactor = 0.05;
        yFactor = 0.08;
        tFactor = 0.04;
    end
    set_axes(obj, 'YTick', yTicks);
    
    xlabPos = get_xlabel(obj, 'Position');
    set_xlabel(obj, 'Position', xlabPos + [0 xFactor*yRange 0]);
    
    ylabPos = get_ylabel(obj, 'Position');
    xRange  = abs(diff(get_axes(obj, 'XLim')));
    set_ylabel(obj, 'Position', ylabPos + [yFactor*xRange 0 0]);
    
    titlePos = get_title(obj, 'Position');
    set_title(obj, 'Position', titlePos - [0 tFactor*yRange 0]);
end

select(obj, origSelection);

set_axes(obj, 'PlotBoxAspectRatioMode', 'Manual');
set_axes(obj, 'PlotBoxAspectRatio', [2 1.25 1]);
    
end


