function y = sign(a)

import misc.ispset;
import pset.pset;


transposed_flag = false;
if a.Transposed,
    a.Transposed = false;
    transposed_flag = true;
end

% Check if the output should also be a pset or just a numeric array
if a.NbChunks > 1,
    y = pset.nan(size(a,1), size(a,2));
else
    y = nan(size(a,1), size(a,2), a.Precision);
end

s.type = '()';
for i = 1:a.NbChunks
    [indexa, dataa] = get_chunk(a,i); 
    s.subs = {1:a.NbDims, indexa};    
    y = subsasgn(y, s, sign(dataa));
end

if transposed_flag,
    a.Transposed = true;
    if ispset(y),
        y.Transposed = true;
    end
end
