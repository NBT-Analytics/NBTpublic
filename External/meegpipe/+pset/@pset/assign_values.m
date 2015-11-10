function obj = assign_values(obj, otherObj)
% ASSIGN_VALUES - Assign values from another pointset

if ~isa(otherObj, 'pset.pset'),
    error('Second argument must be a pset.pset object');
end

if ~all(size(obj) == size(otherObj)),
    error('Dimensions of the two pset objects do not match');
end

for i = 1:otherObj.NbChunks
    [index, dataOtherObj] = get_chunk(otherObj, i);
    if otherObj.Transposed,        
        s.subs = {index, 1:nb_dim(otherObj)};        
    else
        s.subs = {1:nb_dim(otherObj), index};        
    end
    s.type = '()';
    obj = subsasgn(obj, s, dataOtherObj);
end

end