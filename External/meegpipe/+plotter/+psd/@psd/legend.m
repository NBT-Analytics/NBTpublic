function h = legend(h, varargin)
% LEGEND - Create figure legend
%
% legend(h)
%
% See also: plotter.psd

% Description: Create figure legend
% Documentation: class_plotter_psd.txt

h = set_legend(h, varargin{:});
h = set_legend(h, 'Visible', 'on');

end