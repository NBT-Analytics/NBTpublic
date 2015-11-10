function value = get_scale(obj, idx)
% GET_SCALE - Get plot scale
%
% value = get_scale(h)
% value = get_scale(h, idx)
%
% Where
%
% H is a plotter.eegplot handle
%
% VALUE is the plot scale (a double precision scalar). If multiple plots
% are overlaid on the same figure, VALUE will be an array of values as
% individual plots might have individual scales.
%
% IDX is an array of indices, determining the plots whose scales should be
% retrieved. If not provided, the scales of all overlaid plots will be
% returned.
%
% See also: set_scale

% Description: Get plot scale
% Documentation: class_plotter_eegplot.txt

if nargin < 2 || isempty(idx),
    value = obj.ScaleVal;
else
    value = obj.ScaleVal(idx);
end



end