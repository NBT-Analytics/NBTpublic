function [stats] = nbt_cdfcalc_modified(c1)
[yy,xx,n,emsg,eid] = cdfcalc(c1);

if ~isempty(eid)
   error(sprintf('stats:cdfplot:%s',eid),emsg);
end

% Create vectors for plotting
k = length(xx);
n = reshape(repmat(1:k, 2, 1), 2*k, 1);
xCDF    = [-Inf; xx(n); Inf];
yCDF    = [0; 0; yy(1+n)];

stats.xCDF= xCDF;
stats.yCDF = yCDF;
stats.mean = nanmean(c1);
stats.std = nanstd(c1);
stats.median = nanmedian(c1);

f = normcdf(xCDF,stats.mean,stats.std);
% Now plot the sample (empirical) CDF staircase.
% hCDF = 
% figure
% plot(xCDF , yCDF);
% grid  ('on')
% xlabel('x')
% ylabel('F(x)')
% title ('Empirical CDF')
% hold on
% plot(xCDF,f,'m')
% legend('Empirical','Theoretical','Location','NW')



