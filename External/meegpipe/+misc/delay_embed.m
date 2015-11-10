function Y = delay_embed(X, k, step, shift)
% DELAY_EMBED - Delays-embed a signal
%
% Y = delay_embed(x, k, tau, shift)
%
% Where
%
% K is te embedding dimension
%
% TAU is the embedding delay
%
% SHIFT is the embedding shift
%
% Y is the delay-embedded reconstructed state space, i.e. a KxT matrix
%
%
% See also: misc

import misc.isnatural;
import misc.isinteger;
import misc.delay_embed;

if nargin < 4 || isempty(shift), shift = 0; end
if nargin < 3 || isempty(step), step = 1; end
if nargin < 2 || isempty(k) || isempty(X),
    error('Not enough input arguments');
end

% deal with the case of multiple input signals
if iscell(X),
    Y = cell(size(X));
    if size(X,1) && numel(k) == 1,
        k = repmat(k, size(X,1), 1);        
    end
    if size(X,1) && numel(shift) == 1,
        shift = repmat(shift, size(X,1), 1);        
    end
    if size(X,1) && numel(step) == 1,
        step = repmat(step, size(X,1), 1);        
    end
    for i = 1:size(X,1)
        for j = 1:size(X,2)
            Y{i, j} = delay_embed(X{i, j}, k(i), step(i), shift(i));
        end
    end
    return;
end

if ~isnatural(k) ,
    error('delay_embed:invalidEmbeddingDim', ...
        'The embedding dimension must be a natural number');
end
if ~isinteger(shift),
    error('delay_embed:invalidEmbedShift', ...
        'The embedding shift must be an integer number');
end
if ~isnatural(step),
    error('delay_embed:invalidTau', ...
        'The embedding delay must be a natural number');
end

n = size(X,1);
embedDim = k * n;
embedSampleWidth = (k-1) * step + 1;
extraSample = shift + embedSampleWidth - 1;
extraSampleL = floor(extraSample/2);
extraSampleR = extraSample - extraSampleL;

X = [X(:,extraSampleL:-1:1) X X(:,end:-1:end-extraSampleR+1)];
embed_samples = (size(X,2) - shift) - embedSampleWidth + 1;

Y = nan(embedDim, embed_samples, class(X));

for j = 1:k
   s = (shift+step*(j-1)+1); 
   Y((j-1)*n+1:j*n,:) = X(:,s:(s+embed_samples-1));
end

Y = flipud(Y);

