function y = mtimes(a, b)
% * Matrix multiply.
%
%   A*B is the matrix product of A and B, where A is a pset object and B
%   can be either a scalar matrix or a pset object.
%
% See also: pset.pset


import misc.ispset;
import misc.sizeof;
import pset.pset;
import misc.subset;
import pset.globals;
import pset.pset;

n_b = prod(size(b)); %#ok<*PSIZE>
n_a = prod(size(a));

if n_b > 1 && n_a>1 && size(a,2)~=size(b,1)
    error('pset:pset:plus:dimensionMismatch', 'Data dimensions do not match.');
end

% If one of the two inputs is a scalar, call function times()
if n_a < 2 || n_b < 2,
    y = a.*b;
    return;
end

transpose_flag = false;
if ~ispset(a),
    tmp = a.';
    a = b;
    a.Transposed = ~a.Transposed;
    b = tmp;
    transpose_flag = true;
end

% Initialize output
if all(size(b,1) == size(b,2)),
    % Special case, the output physioset has the same dimensions as the
    % input physioset, so we can reuse it to hold the result
    y = a;
else
    if transpose_flag,
        if max(size(b,2), size(a,1)) < nb_pnt(a),
            y = zeros(size(b,2), size(a,1));
            if a.Transposed,
                y = y';
            end
        else
            y = pset.zeros(size(b,2), size(a,1));
            y.Transposed = a.Transposed;
        end
    else
        if max(size(a,1), size(b,2)) < nb_pnt(a),
            y = zeros(size(a,1),size(b,2));
        else
            y = pset.zeros(size(a,1),size(b,2));
        end
    end
end

for i = 1:a.NbChunks
    [indexa, dataa] = get_chunk(a, i);
    
    if a.Transposed,
        if ispset(b)
            for j = 1:b.NbChunks
                [indexb, datab] = get_chunk(b, j);
                s.type = '()';
                s.subs = {indexa, indexb};
                y = subsasgn(y, s, dataa*datab);
            end
        else
            datab = b;
            indexb = 1:size(b,2);
            s.type = '()';
            s.subs = {indexa, indexb};
            y = subsasgn(y, s, dataa*datab);
        end
    else
        if n_b < 2,
            datab = b(1);
        else
            s.type = '()';
            s.subs = {indexa, 1:size(b,2)};
            datab = subsref(b, s);
        end
        
        y = y + (dataa*datab);
        
    end
end

if transpose_flag && ispset(y),
    y.Transposed = ~y.Transposed;
elseif transpose_flag,
    y = y';
end
if transpose_flag && size(b,1)~=size(b,2),
    a.Transposed = ~a.Transposed;
end

if ispset(y),
    y.Writable = a.Writable;
end
