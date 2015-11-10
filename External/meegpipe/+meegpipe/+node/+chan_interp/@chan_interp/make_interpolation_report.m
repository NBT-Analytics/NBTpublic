function make_interpolation_report(obj, chanGroups, data, badIdx, A)


if ~do_reporting(obj), return; end

verbose = is_verbose(obj);
verboseLabel = get_verbose_label(obj);
nn   = get_config(obj, 'NN');

if verbose
    fprintf( [verboseLabel, 'Reporting on interpolated time-series ...']);
end
rep = get_report(obj);
print_title(rep, 'Interpolation report', get_level(rep) + 1);

snapshotPlotter = physioset.plotter.snapshots.new(...
    'MaxChannels',      Inf, ...
    'WinLength',        20, ...
    'NbBadEpochs',      0, ...
    'NbGoodEpochs',     2, ...
    'Channels',         chanGroups);

snapshotRep = report.plotter.new(...
    'Plotter',              snapshotPlotter, ...
    'Title',                'Interpolation snapshots', ...
    'PrintGalleryTitle',    false);

embed(snapshotRep, rep);

print_title(rep, 'Interpolated time-series', get_level(rep) + 2);
print_paragraph(snapshotRep, [...
    'Interpolated channels plotted together with the %d nearest ' ...
    'neighbours that were used as ' ...
    'reference for the interpolation'], nn);

generate(snapshotRep, data);

if verbose, fprintf('[done]\n\n'); end

if verbose
    fprintf( [verboseLabel, 'Reporting on interpolation weights ...']);
end

myPlotter = plotter.topography.new(...
    'MapLimits', 'maxmin', ...
    'ColorBar',  true, ...
    'Visible',   false);
myPlotter = spt.plotter.topography.new('Plotter', myPlotter);
topoRep = report.plotter.new('Plotter',  myPlotter);

embed(topoRep, rep);

print_title(rep, 'Interpolation weights', get_level(rep) + 2);
print_paragraph(topoRep, ...
    'Interpolation weights for each interpolated channel');

sens = sensors(data);
topoNames = labels(subset(sens, badIdx));
generate(topoRep, sens, A, topoNames);

if verbose, fprintf('[done]\n\n'); end

end
