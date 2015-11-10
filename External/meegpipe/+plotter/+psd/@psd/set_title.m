function h = set_title(h, varargin)
% SET_TITLE - Set title property values
%
% set_title(h, propName, propValue)
%
%
% See also: get_title

% Description: Set title properties
% Documentation: class_plotter_psd.txt

if isempty(h.Axes), return; end

titleH = get(h.Axes, 'Title');

if isempty(titleH), 
    error('I can''t set properties of a non-existent title');
end

set(titleH, varargin{:});




end