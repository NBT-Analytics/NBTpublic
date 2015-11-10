function generate_rank_report(rep, rankIndex, rejIdx, minRank, ...
    maxRank, rankStats, data, ev)

import meegpipe.node.bad_epochs.criterion.rank.rank;
import report.gallery.gallery;

verbose         = is_verbose(rep);
verboseLabel    = get_verbose_label(rep);
verboseLabel    = [verboseLabel '    '];

myGallery       = gallery;

if verbose,
    fprintf([verboseLabel ...
        'Plotting rank values across channels...']);
end

% Plot rank values versus epoch index
hFig = rank.plot_epoch_vs_rank(rankIndex, rejIdx, minRank, maxRank, ...
    rankStats);
caption = 'Rejection criterion values across epochs';
print_figure(myGallery, hFig, rep, 'epoch_ranks', caption);

% Plot PDF of rank values
hFig = rank.plot_rank_pdf(rankIndex, rejIdx, minRank, maxRank, ...
    rankStats);
caption = 'PDF for the epoch rejection criterion values';
print_figure(myGallery, hFig, rep, 'ranks_pdf', caption);

print_title(rep, 'Epoch statistics', get_level(rep) + 1);
fprintf(rep, myGallery);
if verbose, fprintf('[done]\n\n'); end

% Plot a few bad epochs
if verbose,
    fprintf([verboseLabel ...
        'Plotting a few bad and borderline epochs ...']);
end
rank.plot_bad_epochs(rep, rankIndex, rejIdx, minRank, maxRank, ...
    data, ev);
if verbose, fprintf('[done]\n\n'); end


end