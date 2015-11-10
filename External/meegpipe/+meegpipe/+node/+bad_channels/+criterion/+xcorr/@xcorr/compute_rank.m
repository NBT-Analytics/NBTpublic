function rankVal = compute_rank(obj, data)
% COMPUTE_RANK - Ranks bad channels using a cross-correlation criterion

import meegpipe.node.bad_channels.bad_channels;
import filter.plotter.fvtool2.fvtool2;
import report.plotter.plotter;
import mperl.join;
import misc.eta;
import report.gallery.gallery;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

%% Configuration options
nn          = get_config(obj, 'NN');

if isempty(nn), nn = 10; end

%% Reject data channels

if verbose,
    
    fprintf([verboseLabel ...
        'Computing local cross-correlations across channels...']);
    
end


%% Cross correlation of each channel with its nearest neighbors
sens = sensors(data);

rankVal = zeros(size(data,1), 1);
tinit   = tic;
for i = 1:numel(rankVal)
    
    d = get_distance(sens, i);
    
    [~, sortIdx] = sort(d, 'ascend');
    
    idx = sortIdx(2:min(nn, numel(d)));
    
    for j = 1:numel(idx)
       thisCorr = xcorr(data(i,:), data(idx(j),:), 0, 'coeff');
       if isnan(thisCorr),
           % NaN due to one of either of the two channels being flat
           continue;
       end
       rankVal(i) = rankVal(i) + abs(thisCorr);
    end
    
    
    rankVal(i) = rankVal(i)/numel(idx);
    
    if verbose,
        eta(tinit, numel(rankVal), i);
    end
    
end

if verbose, fprintf('\n\n'); end

end


