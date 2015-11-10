function val = get_title(h, varargin)
% GET_TITLE - Get title property values
%
% val = get_title(h, prop)
%
%
% See also: set_title

% Description: Get title property values
% Documentation: class_plotter_psd.txt

val = [];
if isempty(h.Axes), return; end

titleH = get(h.Axes, 'Title');

if isempty(titleH), return; end

val = get(titleH, varargin{:});




end