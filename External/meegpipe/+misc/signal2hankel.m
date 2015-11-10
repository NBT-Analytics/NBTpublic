function H = signal2hankel(x, embeddim)
%

import misc.ispset;
import misc.subset;

if nargin < 2 ||  isempty(embeddim), embeddim = 1; end

if ispset(x),
    tmp = delay_embed(x, embeddim, 1);
else
    tmp = misc.delay_embed(x, embeddim, 1);
end
%H  = flipud(subset(tmp, [],1:(size(x,2)-embeddim+1)));
H = flipud(tmp);