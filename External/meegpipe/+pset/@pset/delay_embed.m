function y = delay_embed(a, k, step)
% delay_embed - Delay-embeds an eegset object
%
%   Y = delay_embed(A, K, DELAY) where A is an eegset object, K is the
%   embedding dimension and DELAY is the embedding delay (in points).
%
% See also: pset.pset

import misc.delay_embed;
import pset.pset;

if nargin < 3 || isempty(step), step = 1; end
if nargin < 2 || isempty(k) || isempty(a),
    error('pset:delay_embed:invalidInput',...
        'Not enough input arguments');
end

if k < 0,
    error('pset:delay_embed:invalidDim',...
        'The embedding factor must be a natural number.');
end

if step < 1,
    error('pset:delay_embed:invalidDelay',...
        'The embedding delay must be a natural number');
end

transposed_flag = false;
if a.Transposed,
    a.Transposed = false;
    transposed_flag = true;
end

% Initialize output
y = pset.nan(size(a,1)*k, size(a,2));

s.type = '()';
s2.type = '()';
for i = 1:a.NbChunks
   indexa = get_chunk(a, i);
   indexa2 = [indexa indexa(end)+1:min(indexa(end)+(k-1)*step, a.NbPoints)];
   s.subs = {1:y.NbDims, indexa};
   s2.subs = {1:a.NbDims, indexa2};
   dataa = delay_embed(subsref(a, s2), k, step);
   y = subsasgn(y, s, dataa(1:y.NbDims, :));   
end

if transposed_flag,
    a.Transposed = true;
    y.Transposed = true;
end



end
