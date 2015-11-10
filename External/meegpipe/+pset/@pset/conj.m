function obj = conj(obj)
% CONJ Complex conjugate
%
%   OBJ2 = CONJ(OBJ) is the complex conjugate of a pset object OBJ.
%
% See also: pset.pset, pset.CTRANSPOSE

select(obj, 'all');

writable = obj.Writable;
obj.Writable = true;

s.type = '()';
for i = 1:obj.NbChunks
    [index, data] = get_chunk(obj, i);
    data = conj(data);
    if obj.Transposed,        
        s.subs = {index, 1:nb_dim(obj)};        
    else
        s.subs = {1:nb_dim(obj), index};        
    end    
    obj = subsasgn(obj, s, data);
end
obj.Writable = writable;
    
restore_selection(obj);