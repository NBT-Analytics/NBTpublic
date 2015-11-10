function y = flipud(obj)
% FLIPUD Flip pset object in up/down direction.
%
%   OBJ2 = FLIPUD(OBJ) returns OBJ with columns preserved and rows flipped
%   in the up/down direction.
%
% See also: pset.pset

y = copy(obj);
writable = obj.Writable;
y.Writable = true;
s.type = '()';
for i = 1:obj.NbChunks
    [index, data] = get_chunk(obj, i);
    data = flipud(data);
    if y.Transposed,        
        s.subs = {index, 1:obj.NbDims};        
    else
        s.subs = {1:obj.NbDims, index};        
    end    
    y = subsasgn(y, s, data);
end
y.Writable = writable;
    

