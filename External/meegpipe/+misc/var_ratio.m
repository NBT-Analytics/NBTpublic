function y = var_ratio(x, ev_s, ev_n, factor)
% var_ratio - Ratio of variance

if nargin < 4 || isempty(factor),
    factor = .5;
end

import misc.epoch_get;
import misc.center;

s_epochs = epoch_get(x, ev_s);
n_epochs = epoch_get(x, ev_n);

s_var = 0;
if iscell(s_epochs),
    n_points = 0;
    for i = 1:length(s_epochs),
       s_epochs{i} = detrend(center(s_epochs{i})')';
       s_var = s_var+sum(sum(s_epochs{i}.^2));
       n_points = n_points + numel(s_epochs{i}); 
    end
    s_var = s_var./n_points;
else
    s_epochs = reshape(s_epochs,size(s_epochs,1), size(s_epochs,2)*size(s_epochs,3));
    s_var = var(s_epochs,1,2);
end

n_var = 0;
if iscell(n_epochs),
    n_points = 0;
    for i = 1:length(n_epochs),
       n_epochs{i} = detrend(center(n_epochs{i})')';
       n_var = n_var+sum(sum(n_epochs{i}.^2));
       n_points = n_points + numel(n_epochs{i}); 
    end
    n_var = n_var./n_points;
else
    n_epochs = reshape(n_epochs,size(n_epochs,1), size(n_epochs,2)*size(n_epochs,3));
    n_var = var(n_epochs,1,2);
end

y = s_var/(n_var.^factor);


