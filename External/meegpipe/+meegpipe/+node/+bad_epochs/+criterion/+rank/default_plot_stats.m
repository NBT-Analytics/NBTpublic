function stats = default_plot_stats()
% DEFAULT_PLOT_STATS - Default statistics to plot in HTML report

stats = mjava.hash;
stats('5%') = @(x) prctile(x, 5);
stats('95%') = @(x) prctile(x, 95);
stats('median') = @(x) median(x);
stats('mean') = @(x) mean(x);
stats('median-mad') = @(x) median(x) - mad(x);
stats('median+mad') = @(x) median(x) + mad(x);


end