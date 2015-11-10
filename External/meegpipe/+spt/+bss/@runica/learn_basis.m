function obj = learn_basis(obj, data, varargin)


import runica.runica;

if is_verbose(obj),
    verbose = 'on';
else
    verbose = 'off';
end

obj = apply_seed(obj);

[a,b] = runica(data(:,:), ...
    'verbose',      verbose, ...
    'randstate',    get_seed(obj), ...
    'extended',     obj.Extended);

warning('on', 'MATLAB:RandStream:ActivatingLegacyGenerators');

W     = a*b;
A     = pinv(W);

selection = 1:size(W,1);

obj.W = W;
obj.A = A;
obj.ComponentSelection = selection;
obj.DimSelection       = 1:size(data,1);

end