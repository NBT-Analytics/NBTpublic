function h = set_axes(h, varargin)
% SET_AXES - Set Axes properties
%
% set_axes(h, 'propName', propValue)
%
% See also: plotter.psd

% Description: Set Axes properties
% Documentation: class_plotter_psd.txt

if ~isempty(h.Axes),
    set(h.Axes, varargin{:});
end




end