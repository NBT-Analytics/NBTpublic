function A = bprojmat_win(obj, fullMatrix)

if nargin < 2 || isempty(fullMatrix),
    fullMatrix = false;
end

if isempty(obj.BSSwin),
    A = [];
    return;
end

A = cell(1, numel(obj.BSSwin));

for i = 1:numel(obj.BSSwin)
    A{i} = bprojmat(obj.BSSwin{i}, true);
    if ~fullMatrix,
        A{i} = A{i}(obj.DimSelection, obj.ComponentSelection);
    end
end

A = reshape(cell2mat(A), size(A{1},1), size(A{1},2), numel(A));

end