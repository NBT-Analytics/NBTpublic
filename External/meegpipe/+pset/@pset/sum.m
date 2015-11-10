function y = sum(a, dim)
% SUM Sum of elements
%
%   Y = SUM(A, DIM)
%
% See also: pset.pset

import pset.globals;
import misc.sizeof;

if nargin < 2 || isempty(dim), dim = 1; end


if dim == 1,
    if a.Transposed
        % Sum accross points
        y = 0;
        for i = 1:a.NbChunks
            [~, dataa] = get_chunk(a, i);
            y = y + sum(dataa);            
        end        
    else
        % Sum accross dimensions
        if size(a,2) > globals.get.LargestMemoryChunk/sizeof(a.Precision),
            y = pset.zeros(1,size(a,2));
        else
            y = zeros(1,size(a,2),a.Precision);
        end
        for i = 1:a.NbChunks
            [indexa, dataa] = get_chunk(a, i);
            s.subs = {1, indexa};
            s.type = '()';
            y = subsasgn(y, s, sum(dataa));
        end
    end
    
elseif dim == 2,
    if a.Transposed,
        % Sum accross dimensions
        if size(a,2) > globals.get.LargestMemoryChunk/sizeof(a.Precision),
            y = pset.zeros(1,size(a,1),a.Precision);
            y.Transposed = true;
        else
            y = zeros(size(a,1),1);
        end
        for i = 1:a.NbChunks
            [indexa, dataa] = get_chunk(a, i);
            s.subs = {indexa,1};
            s.type = '()';
            y = subsasgn(y, s, sum(dataa,2));            
        end
    else
        % Sum accross points
        y = 0;
        for i = 1:a.NbChunks
            [~, dataa] = get_chunk(a, i);
            y = y + sum(dataa,2);            
        end   
    end
    
else
    error('pset:InvalidRange', ...
        'A pset object has only two dimensions.');
end

