function generate_erp_topos(rep, sens, wv, wvStd, tPeak)

import meegpipe.node.globals;
import report.gallery.gallery;
import plotter.topography.topography;

visible = globals.get.VisibleFigures;


myGallery = gallery('Title', 'Mean topographies', 'Level', 3);

wvStd = 20*log10(wvStd);

% Plot mean topography
for i = 1:size(wv,2)
    
    topoPlotter = topography(...
        'Visible',   visible, ...
        'MapLimits', [min(wv(:)) max(wv(:))]);
    
    h = plot(topoPlotter, sens, wv(:,i));
    colorbar(h);
    
    name = sprintf('erp-topo-mean-%dms', round(tPeak(i)));
    fileName = print_image(rep, name, false);
    caption = sprintf('Mean topography at t = %d ms', round(tPeak(i)));
    myGallery   = add_figure(myGallery, fileName, caption);
    
    
end


fprintf(rep, myGallery);

myGallery = gallery('Title', 'Standard deviation topographies', 'Level', 3);

% Plot the standard deviation
for i = 1:size(wvStd,2)
    
    plotSensor = ~isnan(wvStd(:,i)) & ~isinf(wvStd(:,i));
    thisSens = subset(sens, plotSensor);
    
    topoPlotter = topography(...
        'Visible',   visible, ...
        'MapLimits', [min(wvStd(plotSensor,i)) max(wvStd(plotSensor,i))]);
    
    h = plot(topoPlotter, thisSens, wvStd(plotSensor,i));
    colorbar(h);
    set_colorbar_title(h, 'String', 'dB');
    
    name = sprintf('erp-topo-std-%dms', round(tPeak(i)));
    fileName = print_image(rep, name, false);
    caption = sprintf('Standard deviation of mean topography at t = %d ms', ...
        round(tPeak(i)));
    myGallery   = add_figure(myGallery, fileName, caption);
end

fprintf(rep, myGallery);

end