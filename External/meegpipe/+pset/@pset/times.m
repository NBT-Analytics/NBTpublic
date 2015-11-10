function y = times(a, b)
% .* pset multiplication.
%
%   A.*B denotes element-by-element multiplication.
%
% See also: pset.pset

import misc.ispset;

% Check data dimensions
if ~all(size(a)==size(b)) && ~((prod(size(a))==1) || prod(size(b))==1), %#ok<PSIZE>
    error('times:dimensionMismatch', 'Data dimensions do not match.');
end

if ~ispset(a),
    tmp = a;
    a = b;
    b = tmp;
end

y = a;

for i = 1:a.NbChunks
    [index, dataa] = get_chunk(a, i);
    if ispset(b),
        [~,datab] = get_chunk(b, i);
    else
        if numel(b)<2,
            datab = b(1);
        else
            if a.Transposed,
                datab = b(index, :);
            else
                datab = b(:, index);
            end
        end
    end
    if a.Transposed,
        s.subs = {index, 1:nb_dim(a)};
    else
        s.subs = {1:nb_dim(a), index};
    end
    s.type = '()';
    y = subsasgn(y, s, dataa .* datab);
end
if ispset(y)
    y.Writable = a.Writable;
end