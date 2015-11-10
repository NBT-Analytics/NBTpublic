function y = repmat(a, dim1, dim2)
% REPMAT Replicate and tile a pset object
%
%   Y = repmat(A, M, N) creates a large pset object Y consiting of an
%   M-by-N tiling of copies of A.
%
% See also: pset.pset

import misc.ispset;
import misc.sizeof;
import pset.globals;

if nargin < 3 || isempty(dim2), dim2 = 1; end
if nargin < 2 || isempty(dim1), dim1 = 1; end


transposed_flag = false;
if a.Transposed,
    transposed_flag = true;
    tmp = dim2;
    dim1 = dim2;
    dim2 = tmp;
    a.Transposed = false;
end

if (dim1*a.NbDims + dim2*a.NbPoints)*sizeof(a.Precision) > globals.evaluate.LargestMemoryChunk,
    y = pset.nan(dim1*a.NbDims, dim2*a.NbPoints);
else
    y = nan(dim1*a.NbDims, dim2*a.NbPoints, a.Precision);
end


s.type = '()';
for ii = 1:dim2
    for i = 1:a.NbChunks
        [dataa, indexa] = getChunk(a,i);
        for j = 1:dim1
            s.subs = {(j-1)*a.NbDims+1:a.NbDims*j,...
                (ii-1)*a.NbPoints+indexa};
            y = subsasgn(y, s, dataa);
        end
    end
end

if transposed_flag,
    a.Transposed = true;
    if ispset(y),
        y.Transposed = true;
    end
end
