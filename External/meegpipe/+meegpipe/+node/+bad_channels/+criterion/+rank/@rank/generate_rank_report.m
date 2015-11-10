function generate_rank_report(rep, data, rankVal, rejIdx, minRank, ...
    maxRank, rankStats)
% GENERATE_RANK_REPORT - Generates report on bad channels and their rank
%
%
% See also: bad_channels


import mperl.file.spec.catfile;
import misc.unique_filename;
import rotateticklabel.rotateticklabel;
import plot2svg.plot2svg;
import meegpipe.node.bad_channels.criterion.rank.rank;
import meegpipe.node.globals;
import report.gallery.gallery;
import physioset.plotter.snapshots.snapshots;
import inkscape.svg2png;
import mperl.join;
import misc.print;

verbose         = is_verbose(rep);
verboseLabel    = get_verbose_label(rep);
verboseLabel    = [verboseLabel '    '];

myGallery       = gallery;

sens = sensors(data);

sensType = upper(regexprep(class(sens), '^(.+?)\.([^\.]+)$', '$2'));

%% Generate a variance topography, if EEG or MEG sens
if ismember(sensType, {'EEG', 'MEG'}) && has_coords(sens),
    
    if verbose,
        fprintf([verboseLabel 'Generating rank topographies...']);
    end
    
    rank.make_topo_plots(sens, rankVal, rejIdx);
    
    % Print to .png format
    fileName = catfile(get_rootpath(rep), ['rank-topo-' sensType '.png']);
    fileName = unique_filename(fileName);
    
    caption     = sprintf('Channel rank topography for %s sensors', ...
        class(sens));

    [path, name] = fileparts(fileName);
    tmpPdfFile = [catfile(path, name) '.pdf'];
    print('-dpdf', tmpPdfFile);
    svg2png(tmpPdfFile);
    delete(tmpPdfFile);
  
    myGallery   = add_figure(myGallery, fileName, caption);
    
    if verbose, fprintf('[done]\n\n'); end
    
end

%% Generate a variance plot with upper and lower boundaries
if verbose,
    fprintf([verboseLabel ...
        'Plotting rank values across channels...']);
end

rank.make_rank_plots(sens, rankVal, rejIdx, minRank, ...
    maxRank, rankStats);

% Print to .svg and .png format
fileName = catfile(get_rootpath(rep), ['var-plot-' sensType '.svg']);
fileName = unique_filename(fileName);

caption     = sprintf(...
    [ ...
    'Variance for %s sensors. Rejected sensors (if any) ' ...
    'are marked with red circles' ...
    ], ...
    class(sens));

% IMPORTANT: Print to png AFTER printing to svg. For some reason, printing
% to .png during terminal mode emulation screws the figures looks!
evalc('plot2svg(fileName, gcf);');
myGallery = add_figure(myGallery, fileName, caption);

svg2png(fileName);

close;

if verbose, fprintf('[done]\n\n'); end

%% Generate few snapshots
if verbose,
    fprintf([verboseLabel 'Plotting snapshots...']);
end

selected = false(1, numel(rejIdx));
chanList = {};

while ~all(selected),
    thisChanIdx = rejIdx(find(~selected(:), 1, 'first'));
    firstChan   = max(1, thisChanIdx - 5);
    lastChan    = min(size(data,1), thisChanIdx + 5);
    selChans    = firstChan:lastChan;
    selected(ismember(rejIdx, selChans)) = true;
    chanList = [chanList; {selChans}]; %#ok<AGROW>
end

myPlotter = snapshots( ...
    'WinLength',    30, ...
    'SVG',          true, ...
    'NbBadEpochs',  0, ...
    'NbGoodEpochs', 2, ...
    'Channels',     chanList, ...
    'Folder',       get_rootpath(rep));

% Temporarily set the bad channels so that they show in red in the plots
set_bad_channel(data, rejIdx);

[figNames, captions] = plot(myPlotter, data);

clear_bad_channel(data, rejIdx);

fileName = [figNames{:}]';
captions = [captions{:}]';
myGallery   = add_figure(myGallery, fileName, captions);

if verbose, fprintf('[done]\n\n'); end


%% Print summary info to report
sensLabels  = labels(sens);
rejLabels = sensLabels(rejIdx);
msg = sprintf( '%d out of %d sensors (%d%%%%) were rejected', ...
    numel(rejIdx), size(data, 1), round(100*numel(rejIdx)/size(data,1)));
print_paragraph(rep, msg);

rejLabels = cellfun(@(x) ['__' x '__'], rejLabels, ...
    'UniformOutput', false);
rejLabels = join(', ', rejLabels);

print_paragraph(rep, ...
    'Selected channels for rejection: %s', rejLabels);
fprintf(rep, myGallery);


end
