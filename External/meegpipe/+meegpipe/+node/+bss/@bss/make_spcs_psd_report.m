function make_spcs_psd_report(obj, ics, rep, verbose, verboseLabel)

if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs PSDs...']);
end

% This will ensure that one plot will be generated for each IC
myPlotter = get_config(obj, 'PSDPlotter');
set_config(myPlotter, 'Channels', num2cell(1:size(ics,1)));

psdRep = report.plotter.new(...
    'Plotter',  myPlotter, ...
    'Title',    'Activations PSDs');

print_title(rep, 'SPCs power spectral densities', get_level(rep) + 1);

generate(embed(psdRep, rep), ics);

if verbose, fprintf('\n\n'); end

end