function pErr = amari_index(P, varargin)
% AMARI_INDEX - Amari performance index
%
% 
% pErr = amari_index(P)
% pErr = amari_index(P, 'range', [0 1])
% 
% Where
%
% P=W*A where A is the true mixing matrix and W is the estimated separting
% matrix.
%
% PERR is the Amari performance index, which is in the range [0, d-1] with
% d the dimensionality of matrix P. See key 'Range' below to specify the
% range of the index.
%
%
% ## Optional key/value pairs:
%
% 'Range'       : (vector) A vector determining the desired range for the
%                 index. For instance, range=[0 1] will make the index take
%                 values between 0 and 1, regardless of the dimensionality
%                 of P. 
%                 Default: [], i.e use original (dim-dependent range)
%
% ## References:
%
% [1] Amari et al, A new learning algorithm for blind signal separation,
%     Advances in Neural Information Processing Systems, 8, 1996.
%
%
% See also: spt

import misc.process_arguments;

opt.range = [];

[~, opt] = process_arguments(opt, varargin);

d = size(P,1);
P = abs(P);
pErr = 0;
for i = 1:d
    for j=1:d
        pErr = pErr + P(i,j)/max(P(i,:))+P(i,j)/max(P(:,j));        
    end
end

pErr = pErr/(2*d)-1;

if ~isempty(opt.range),
    pErr = (pErr/(d-1))*diff(opt.range)+opt.range(1);
end



end