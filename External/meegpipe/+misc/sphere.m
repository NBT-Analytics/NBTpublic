function [pset_out, A] = sphere(pset)
% Unit variance normalization of a pointset


if iscell(pset),
    pset_out = cell(size(pset));
    for i = 1:numel(pset)
       pset_out{i} = sphere(pset{i}); 
    end
    return;
end

A = chol(cov(pset'));
pset_out = pinv(A)'*pset;


