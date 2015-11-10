function [ccoef, lag] = find_shift(template, data, max_lag)
% find_shift - Finds shift between some epochs and a reference epoch

ccoef = nan(length(data),1);
lag = nan(length(data),1);
template = template';
for i = 1:length(data)    
    data{i} = [data{i} zeros(size(data{i},1), size(template,1)-size(data{i},2))];
    data{i} = data{i}';
    [this_c, this_lags] = xcorr(template(:), data{i}(:), max_lag, 'coeff');
    [ccoef(i), lag(i)] = max(this_c);
    lag(i) = this_lags(lag(i));
end