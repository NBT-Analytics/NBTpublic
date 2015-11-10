function make_spcs_snapshots_report(obj, ics, rep, verbose, verboseLabel)

if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs snapshots...']);
end

snapshotRep = report.plotter.new(...
    'Plotter',  get_config(obj, 'SnapshotPlotter'), ...
    'Title',    'Activations'' snapshots');

embed(snapshotRep, rep);

print_title(rep, 'SPCs snapshots', get_level(rep) + 1);

set_level(snapshotRep, get_level(rep) + 2);

generate(snapshotRep, ics);

if verbose, fprintf('[done]\n\n'); end

end