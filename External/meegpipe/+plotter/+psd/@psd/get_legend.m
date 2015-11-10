function val = get_legend(h, varargin)
% GET_LEGEND - Get legend properties
%
% val = get_legend(h, propName)
% str = get_legend(h)
%
% Where
%
% H is a plotter.psd handle
%
% PROPNAME is a string with the valid property name
%
% VAL is the value of the legend property
%
% STR is a struct having as fields all valid legend property names and as
% values the corresponding property values
%
%
% See also: get_legend, plotter.psd

% Description: Set legend property values
% Documentation: class_plotter_psd.txt


val = get(h.Legend, varargin{:});



end