function make_filtering_report(rep, icsIn, icsOut)

import goo.globals;
import physioset.plotter.snapshots.snapshots;
import physioset.plotter.psd.psd;
import report.plotter.plotter;

verbose      = globals.get.Verbose;
verboseLabel = globals.get.VerboseLabel;

% Deactivate verbose mode for any function call
globals.set('Verbose', false);

if verbose
    fprintf( [verboseLabel, 'Generating ICs filtering report...\n\n']);
end

% Snapshots
if verbose
    fprintf( [verboseLabel, '\tGenerating before/after snapshots...']);
end

snapshotPlotter = snapshots(...
    'MaxChannels',  Inf, ...
    'WinLength',    20, ...
    'NbBadEpochs',  0, ...
    'NbGoodEpochs', 3);

snapshotRep = plotter(...
    'Plotter',  snapshotPlotter, ...
    'Title',    'Before/after filtering SPCs snapshots');

print_title(rep, 'Before/after filtering SPCs snapshots', get_level(rep) + 1);

set_level(snapshotRep, get_level(rep) + 2);

generate(embed(snapshotRep, rep), icsIn, icsOut);

if verbose, fprintf('[done]\n\n'); end


% PSDs
if verbose
    fprintf( [verboseLabel, '\tGenerating before/after PSDs...']);
end

plotterObj = plotter.psd.psd(...
    'FrequencyRange',   [3 60], ...
    'Visible',          false, ...
    'LogData',          false);

psdPlotter = psd(...
    'MaxChannels',  size(icsIn, 1), ...
    'Channels',     num2cell(1:size(icsIn,1)), ...
    'WinLength',    30, ...
    'Plotter',      plotterObj); %#ok<FDEPR>

psdRep = plotter(...
    'Plotter',  psdPlotter, ...
    'Title',    'Before/after filtering SPCs PSDs');

print_title(rep, 'Before/after filtering SPCs PSDs', get_level(rep) + 1);

generate(embed(psdRep, rep), icsIn, icsOut);

if verbose, fprintf('\n\n'); end

% Return to original verbose mode
globals.set('Verbose', verbose);

end