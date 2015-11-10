function value = get_line(h, idx, varargin)
% GET_LINE - Gets PSD line properties
%
% value = get_line(h, idx, 'propName')
% value = get_line(h, idx);
% value = get_line(h);
%
% Where
%
% H is a plotter.psd handle
%
% IDX is the index of the PSD whose properties are to be modified.
% Alternatively, IDX can be the "Name" of a PSD. Valid PSD names are listed
% in property PSDName of object H. If IDX is empty, the property values of
% all available PSDs main lines will be returned.
%
% VALUE is the value of the corresponding property if a property
% name is passed as input argument (first call above). 
%
% VALUE is a struct containing all the properties and corresponding values
% for the relevant PSD's main line, if no property name is provided as
% input argument (second call above).
%
% VALUE is a cell array of structs containing all the properties and
% corresponding values for all PSD's main lines, if a single input argument
% is provided (third call above). 
%
% ## Examples: 
%
% % Create a sample PSD plot
% h     = spectrum.welch;
% hpsd  = psd(h, randn(1,1000), 'Fs', 100, 'ConfLevel', 0.95);
% hp    = plot(plotter.psd, hpsd);
% hpsd2 = psd(h, 0.5*randn(1,1000), 'Fs', 100, 'ConfLevel', 0.9);
% plot(hp, hpsd2, 'r'); % Plot second PSD in red
%
% % Get the value of property Style from first PSD's main line
% lineStyle = get_line(hp, 1, 'Style');
%
%
% See also: set_line, get_edges, get_shadow, plotter.psd

% Documentation: class_plotter_psd.txt
% Description: Get PSD main line properties

if nargin < 2, idx = []; end

idx = resolve_idx(h, idx);

value = cell(numel(idx),1);
for i = 1:numel(idx)
   value{i} = get(h.Line{idx(i),1}, varargin{:});    
end
if numel(value) == 1,
    value = value{1};
end


end