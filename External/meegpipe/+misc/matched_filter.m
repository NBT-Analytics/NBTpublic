function y = matched_filter(x, template)
% matched_filter - Matched filter for multidimensional signals
%
%   Y = matched_filter(X, TEMPLATE) where TEMPLATE is a DxM numeric matrix
%   with the template to match and X is the DxN (N>>M) input data matrix.
%   The output Y is a 1xN logical vector with true values located on the
%   locations corresponding to ocurrences of the template in the input
%   data.
%
% See also: misc


verbose = true;

y = nan(1, size(x,2));
[n_dim, n_p] = size(template);
template = template';
template = template(:);
l_x = length(x);
max_iter_by10 = ceil((l_x-n_p+1)/10);
for i = 1:(l_x-n_p+1)
   this_chunk = x(:,i:i+n_p-1)';   
   tmp = corrcoef(this_chunk(:), template);
   y(i) = tmp(1,2); 
   if verbose && ~mod(i, max_iter_by10),
       fprintf('.');
   end
end

% Maximum of the output located at the maximum of the template
[~, max_loc] = max(reshape(template, n_p, n_dim));
max_loc = round(median(max_loc));
y = [nan(1, max(1,max_loc - 1)) y(1,1:end-(max_loc-1))];



end