function W = projmat_win(obj, fullMatrix)

if nargin < 2 || isempty(fullMatrix),
    fullMatrix = false;
end

if isempty(obj.BSSwin),
    W = [];
    return;
end

W = cell(1, numel(obj.BSSwin));

for i = 1:numel(obj.BSSwin)
    W{i} = projmat(obj.BSSwin{i}, true);
    if ~fullMatrix,
        W{i} = W{i}(obj.ComponentSelection, obj.DimSelection);
    end
end

W = reshape(cell2mat(W), size(W{1},1), size(W{1},2), numel(W));
