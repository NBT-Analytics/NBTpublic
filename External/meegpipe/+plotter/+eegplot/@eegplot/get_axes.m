function val = get_axes(h, varargin)
% GET_AXES - Get Axes properties
%
% val = get_axes(h, 'propName')
%
% See also: set_axes

% Description: Get Axes properties
% Documentation: class_plotter_eegplot.txt

if ~isempty(h.Axes),
    val = get(h.Axes, varargin{:});
else
    val = [];    
end


end