function value = get_line(h, idx, varargin)
% GET_LINE - Gets time courses line properties
%
% value = get_line(h, idx, 'propName')
% value = get_line(h, idx);
% value = get_line(h);
%
% Where
%
% IDX is the index of the PSD whose properties are to be modified.
%
% VALUE is the value of the corresponding property if a property
% name is passed as input argument (first call above). 
%
% VALUE is a struct containing all the properties and corresponding values
% for the relevant corresp. eegplot lines, if no property name is provided
% as input argument (second call above).
%
% VALUE is a cell array of structs containing all the properties and
% corresponding values for all eegplot lines, if a single input argument
% is provided (third call above). 
%
%
% See also: set_line, get_edges, get_shadow, plotter.psd

% Documentation: class_plotter_eegplot.txt
% Description: Get eegplot time courses properties

% Deal with multiple selections using recursion
if numel(h.Selection) > 1,
    selection = h.Selection;
    deselect(h, []);
    value = cell(numel(selection),1);
    for i = 1:numel(selection),
        select(h, selection(i));
        value{i} = get_line(h, idx, varargin{:});
    end
    select(h, selection);
    return;
end

if nargin < 2, idx = []; end

if islogical(idx),
    idx = find(idx);
end

if isempty(idx), idx = 1:numel(h.Line{h.Selection}); end

value = cell(numel(idx),1);
for i = 1:numel(idx)
   value{i} = get(h.Line{h.Selection}(idx(i)), varargin{:});    
end
if numel(value) == 1,
    value = value{1};
end


end