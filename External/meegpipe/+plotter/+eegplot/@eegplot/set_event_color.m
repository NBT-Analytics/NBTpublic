function h = set_event_color(h, idx, val)
% SET_EVENT_COLOR - Set colors of event markers
%
% set_event_color(h, idx, val)
%
% Where
%
% H is a plotter.eegplot handle
%
% IDX is an array of event type indices.
%
% VAL is a Kx3 matrix with RGB color specifications
%
%
% ## Notes:
%
%   * The number of rows of VAL must match the number of relevant event
%     markers. However, if VAL has only one row (i.e. if a single color is
%     specified), all event markers will be set to have the provided color
%     specification.
%
% See also: set_event_color

% Description: Set colors of event markers
% Documentation: class_plotter_eegplot.txt

import misc.isnatural;

if nargin < 2 || isempty(idx),
    idx = 1:numel(h.EventLine);
end

if isempty(idx), return; end

if ~isnatural(idx) || ndims(idx) > 2,
    error('Argument IDX must be an array of indices');
end

if size(val, 1) == 1 && numel(idx) > 1,
    val = repmat(val, numel(idx), 1);
end

for i = 1:numel(idx)
    
    set(h.EventLine(idx(i)), 'Color', val(i,:));
    
end


end