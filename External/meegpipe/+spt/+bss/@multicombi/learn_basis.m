function obj = learn_basis(obj, data, varargin)


import multicombi.multicombi;
import efica.efica;

% Set the random number generator state
obj = apply_seed(obj);

try
    W = multicombi(data(:,:), obj.AROrder, false);
catch ME
    if strcmp(ME.identifier, 'MATLAB:nearlySingularMatrix'),
        warning('learn_basis:Singular', ...
            ['multicombi failed due to a close to singular matrix ' ...
            'inversion: falling back to efica']);
        W = efica(data(:,:));
    else
        rethrow(ME);
    end
end

if isempty(W),
    W = randn(size(data,1));
    selection = [];
elseif size(W,1) < size(data,1),
    selection = 1:size(W,1);
    W = [W;randn(size(data,1)-size(W,1), size(data,2))];
else
    selection = 1:size(W,1);
end

A = pinv(W);

obj.W = W;
obj.A = A;
obj.ComponentSelection = selection;
obj.DimSelection       = 1:size(data,1);

end