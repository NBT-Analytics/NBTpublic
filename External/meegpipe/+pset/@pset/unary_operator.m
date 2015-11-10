function obj = unary_operator(obj, op)
% UNARY_OPERATOR - Apply unary operator to pset data values


import misc.ispset;
import pset.pset;

s.type = '()';
for i = 1:obj.NbChunks
    [indexa, dataa] = get_chunk(obj,i);
    s.subs = {1:nb_dim(obj), indexa};
    obj = subsasgn(obj, s, op(dataa));
end
