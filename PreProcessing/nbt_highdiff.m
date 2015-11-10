function out=nbt_highdiff(data)
ff = median(diff(data,2,1),2);
tmp = ff > 5*iqr(ff);
newtmp = nan(floor((length(tmp)-501)/500),1);
for ii = 1:500:length(tmp)-501  
    newtmp(ii) = mean(tmp(ii:ii+500));
end
out = find(newtmp);
end