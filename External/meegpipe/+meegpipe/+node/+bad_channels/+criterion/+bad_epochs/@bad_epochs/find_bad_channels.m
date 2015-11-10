function [idx, rankVal] = find_bad_channels(obj, data, ~)

import misc.eta;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

goo.globals.set('Verbose', false);

%% Configuration options
badEpochsCrit   = get_config(obj, 'BadEpochsCriterion');
evSel           = get_config(obj, 'EventSelector');
maxTh           = get_config(obj, 'Max');


%% Number of bad epochs rejected in every channel
ev = select(evSel, get_event(data));

nbRejected = nan(size(data,1),1);

if verbose,
    fprintf([verboseLabel 'Finding epoch rejections for each channel ...']);
end
tinit = tic;
for i = 1:size(data,1)
    select(data, i);
    try
        evBad = find_bad_epochs(badEpochsCrit, data, ev);
    catch ME
        restore_selection(data);
        rethrow(ME);
    end
    restore_selection(data);
    nbRejected(i) = numel(evBad);
    if verbose,
        eta(tinit, size(data,1), i);
    end
end
if verbose, fprintf('\n\n'); end

%% Apply the threshold to determine which channels to reject
if isa(maxTh, 'function_handle'),
    maxTh = maxTh(nbRejected);
end

if maxTh > 1,
    maxTh = maxTh/numel(ev);
end

rankVal = nbRejected/numel(ev);

idx = find(rankVal >= maxTh);

goo.globals.set('Verbose', verbose);

end
