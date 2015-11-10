function h = set_line(h, idx, varargin)
% SET_LINE - Sets properties of time courses lines
%
% set_line(h, idx, 'Prop1', val1, 'Prop2', val2, ...)
%
% Where
%
% IDX is the index of the eegplot whose properties are to be modified.
%
%
% See also: get_line

% Documentation: class_plotter_eegplot.txt
% Description: Set time courses line properties

% Deal with multiple selections using recursion
if numel(h.Selection) > 1,
    selection = h.Selection;
    deselect(h, []);
    for i = 1:numel(selection),
        select(h, selection(i));
        h = set_line(h, idx);
    end
    select(h, selection);
    return;
end

if nargin < 2,
    return;
end

if islogical(idx),
    idx = find(idx);
end

% This was needed in the past? Why not anymore? Different versions of
% EEGLAB? Do things change when there are bad epochs?
%hLine = flipud(h.Line{h.Selection});
hLine = h.Line{h.Selection};

if isempty(idx),
    idx = 1:numel(hLine);
end

for i = 1:numel(idx)
   set(hLine(idx(i):h.NbTimeSeries:end), varargin{:}); 
end


end