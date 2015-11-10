function obj = learn_basis(obj, data, varargin)

import efica.efica; 

obj = apply_seed(obj);

W = efica(data(:,:));
A = pinv(W);
selection = 1:size(W,1);

obj.W = W;
obj.A = A;
obj.ComponentSelection = selection;
obj.DimSelection       = 1:size(data,1);

end