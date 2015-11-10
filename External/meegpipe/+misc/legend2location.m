function legend2location(location, legH, axH)
% LEGEND2LOCATION - Places the legend according to some standard locations
%
% legend2location(location);
% legend2location(location, legH, axH);
%
% Where
%
% LOCATION is a string identifying a standard legend location. Currently
% only 'NorthEastOutside' is handled. For all others, the builtin MATLAB
% tools will be used.
%
% LEGH is the handle to the figure legend.
%
% AXH is the handle to the axes to which the legend refers.
%
%
% ## Notes:
%
% * This function is handy when printing invisible figures to .svg format
%   using plot2svg. For some reason, the legend of the generated figures
%   are not placed in the correct locations and this function can help with
%   that.
%
% See also: misc

if nargin < 2 || isempty(legH), legH = legend; end

if nargin < 3 || isempty(axH), axH = gca; end

switch lower(location),
    
    case 'northeastoutside',
        
        axPos = get(axH, 'Position');
        
        legPos = get(legH, 'Position');
        
        if isempty(legPos);
            return;
        end
        
        legPos(1) = axPos(1)+ axPos(3) + 0.1*legPos(3);
        
        legPos(2) = axPos(2) + axPos(4) - legPos(4);
        
        set(legH, 'Position', legPos);
        
    otherwise,
        
        set(legH, 'Location', location);
        
end


end