function val = get_xlabel(h, varargin)
% GET_XLABEL - Get X-axis label property values
%
% val = get_xlabel(h, prop)
%
%
% See also: set_xlabel

% Description: Get X-axis label property values
% Documentation: class_plotter_psd.txt

val = [];
if isempty(h.Axes), return; end

xlabelH = get(h.Axes, 'Xlabel');

if isempty(xlabelH), return; end

val = get(xlabelH, varargin{:});




end