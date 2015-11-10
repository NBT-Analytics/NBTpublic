function value = get_shadow(h, idx, varargin)
% GET_SHADOW - Gets PSD shadow properties
%
% value = get_shadow(h, idx, 'propName')
% value = get_shadow(h, idx);
% value = get_shadow(h);
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
% % Get the value of property Style from second PSD's main line
% shadowColor = get_shadow(hp, 2, 'FaceColor');
%
%
% See also: set_shadow, get_edges, get_shadow, plotter.psd

% Documentation: class_plotter_psd.txt
% Description: Get PSD shadow properties

if nargin < 2, idx = []; end

idx = resolve_idx(h, idx);

value = cell(numel(idx),1);
for i = 1:numel(idx)
   if ~isempty(h.Line{idx(i),2}),
       value{i} = get(h.Line{idx(i),2}, varargin{:});    
   end
end
if numel(value) == 1,
    value = value{1};
end


end