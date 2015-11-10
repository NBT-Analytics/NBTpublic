function idxOut = clone(h, idxNew)
% CLONE - Creates a clone of a fvtool2 figure
%
% idxOut = clone(h)
%
%
% See also: plotter.fvtool2

% Description: Creates a clone of a fvtool2 figure
% Documentation: class_plotter_fvtool2.txt

if nargin < 3, idxNew = []; end

idx = h.Selection;
figH = h.FvtoolHandle;
if numel(idx) ~= numel(idxNew),
    idxNew = [];
end

idxOut = nan(size(idx));
for i = 1:numel(idx)
    if isempty(idxNew),
        copyobj(get(figH(idx(i)), 'Children'), figure);    
    else
        copyobj(get(figH(idx(i)), 'Children'), figure(idxNew(i)));    
    end
    idxOut(i) = gcf;
end

    




end