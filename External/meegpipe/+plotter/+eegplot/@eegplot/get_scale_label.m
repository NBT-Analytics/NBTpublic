function value = get_scale_label(obj, varargin)
% GET_SCALE_LABEL - Get property value from plot scale label
%
% value = get_scale_label(obj, 'propName')
%
% See also: set_scale_label

% Description: Get property value from scale label
% Documentation: class_plotter_eegplot.txt

value = get(obj.ScaleNum, varargin{:});


end