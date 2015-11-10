function y = power(a,b)
% .^ Array power
%
%   Y = A.^B
%
% See also pset.pset

import misc.ispset;
import pset.pset;

n_a = prod(size(a)); %#ok<*PSIZE>
n_b = prod(size(b));

if ~all(size(a)==size(b)) && ~(n_a==1 || n_b==1),
    error('pset:pset:power', 'Dimensions of base and exponent do not match.');
end

transposed_flaga = false;
transposed_flagb = false;
if ispset(a) && a.Transposed,
    a.Transposed = false;
    transposed_flaga = true;
end
if ispset(b) && b.Transposed,
    b.Transposed = false;
    transposed_flagb = true;
end

if ispset(a),
    y = a;
elseif ispset(b),
    y = b;
else
    y = nan(size(a,1),size(a,2),a.Precision);
end

if n_b < 2, 
    if ispset(a),
        s.type = '()';
        for i = 1:a.NbChunks
           [indexa, dataa] = get_chunk(a,i); 
           s.subs = {1:nb_dim(a), indexa};
           y = subsasgn(y, s, dataa.^b(1));
        end
    else
        y = a.^b(1);        
    end   
else
    error('power:notImplemented','Not implemented yet!');    
    
end

if transposed_flaga && ispset(a),
    a.Transposed = true;
    if ispset(y),
        y.Transposed = true;
    else
        y = transpose(y);
    end
end

if transposed_flagb && ispset(b),
    b.Transposed = true;
    if ispset(y),
        y.Transposed = true;
    else
        y = transpose(y);
    end
end
