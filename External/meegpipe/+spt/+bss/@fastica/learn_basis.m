function obj = learn_basis(obj, data, varargin)

import fastica.fastica;

% Set the random number generator state
obj = apply_seed(obj);

initGuess = get_init(obj, data);

[A W] = fastica(data(:,:), ...
    'verbose',      'off', ...
    'approach',     obj.Approach, ...
    'g',            obj.Nonlinearity, ...
    'InitGuess',    initGuess);

if isempty(W),
    W = randn(size(data,1));
    selection = [];
elseif size(W,1) < size(data,1),
    selection = 1:size(W,1);
    W = [W;randn(size(data,1)-size(W,1), size(data,2))];
else
    selection = 1:size(W,1);
end

obj.W = W;
obj.A = A;
obj.ComponentSelection = selection;
obj.DimSelection       = 1:size(data,1);


end