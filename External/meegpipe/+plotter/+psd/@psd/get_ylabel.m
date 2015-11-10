function val = get_ylabel(h, varargin)
% GET_YLABEL - Get Y-axis label property values
%
% val = get_ylabel(h, prop)
%
%
% See also: set_ylabel

% Description: Get Y-axis label property values
% Documentation: class_plotter_psd.txt

val = [];
if isempty(h.Axes), return; end

ylabelH = get(h.Axes, 'Ylabel');

if isempty(ylabelH), return; end

val = get(ylabelH, varargin{:});




end