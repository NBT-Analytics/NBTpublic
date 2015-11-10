function y = minus(a, b)
% + Plus. 
%
%   A - B subtracts B from the contents of pset object A. B can be either a
%   numeric array or a pset object.
%
% See also: pset.pset

import misc.ispset;
import pset.pset;

% Check data dimensions
if ~all(size(a)==size(b)) && ~((prod(size(a))==1) || prod(size(b))==1), %#ok<PSIZE>
    error('minus:dimensionMismatch', ...
        'Data dimensions do not match.');
end

factor = 1;
if ~ispset(a),    
    tmp = a;
    a = b;
    b = tmp;
    factor = -1;
end

y = a;

for i = 1:a.NbChunks
    [index, dataa] = get_chunk(a, i);
    if ispset(b),
        [~, datab] = get_chunk(b, i);
    elseif numel(b)==1,
        datab = b(1);
    else
        if a.Transposed,
            datab = b(index, :);
        else
            datab = b(:, index);
        end
    end    
    if a.Transposed,        
        s.subs = {index, 1:nb_dim(a)};        
    else
        s.subs = {1:nb_dim(a), index};        
    end
    s.type = '()';
    y = subsasgn(y, s, factor*(dataa - datab));
end

if ispset(y),
    y.Writable = a.Writable;
end


