function val = get_event_color(h, idx)
% GET_EVENT_COLOR - Get colors of event markers
%
% val = get_event_color(h, idx)
%
% Where
%
% H is a plotter.eegplot handle
%
% IDX is a 1xK array of event type indices
%
% VAL is a Kx3 matrix with RGB color specifications
%
% See also: set_event_color

% Description: Get colors of event markers
% Documentation: class_plotter_eegplot.txt

import misc.isnatural;

if nargin < 2 || isempty(idx),
    idx = 1:numel(h.EventLine);
end

val = [];

if isempty(idx), 
    return; 
end

if ~isnatural(idx) || ndims(idx) > 2,
    error('Argument IDX must be an array of indices');
end

for i = 1:numel(idx)   
    
    thisColor = get(h.EventLine(idx(i)), 'Color');   
    val = [val; thisColor]; %#ok<AGROW>
    
end


end