function obj = learn_basis(obj, data, varargin)

import amica.amica;


obj = apply_seed(obj);

W = amica(data(:,:), 1, ...
    obj.NbMixtures, ...
    obj.MaxIter, ...
    obj.UpdateRho, ...
    obj.MinLL, ...
    obj.IterWin, ...
    obj.DoNewton, ...
    true, ...   % Remove mean?
    false);

A = pinv(W);
selection = 1:size(W,1);

obj.W = W;
obj.A = A;
obj.ComponentSelection = selection;
obj.DimSelection       = 1:size(data,1);



end