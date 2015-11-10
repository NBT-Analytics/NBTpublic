function rankVal = compute_rank(obj, data)
% COMPUTE_RANK - Ranks bad channels using a global variance criterion

import meegpipe.node.bad_channels.bad_channels;
import filter.plotter.fvtool2.fvtool2;
import report.plotter.plotter;
import mperl.join;
import misc.eta;
import report.gallery.gallery;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

%% Configuration options
filterObj   = get_config(obj, 'Filter');
normalized  = get_config(obj, 'Normalize');
nn          = get_config(obj, 'NN');
logScale    = get_config(obj, 'LogScale');

%% Compute raw data variance
rawVar = var(data, [], 2);

rawVar = nonzero_noninf(rawVar);

%% Computer variances after pre-processing filter

if isempty(filterObj),
    
    bandVar = rawVar;
    
else
    
    if isa(filterObj, 'function_handle'),
        filterObj = filterObj(data.SamplingRate);
    end
    
    thisData = copy(data);
    filter(filterObj, thisData);
    
    if verbose,
        
        fprintf([verboseLabel 'Computing channels variance...']);
        
    end
    
    bandVar = var(thisData, [], 2);
    
    % Check that there is no zero variance channels
    bandVar = nonzero_noninf(bandVar);
    
    if verbose, fprintf('\n\n'); end
    
    if normalized,
        bandVar = bandVar./rawVar;
    end
    
end

% Identify channels with abnormal variance
sens = sensors(data);

if ~isempty(nn) && ~isinf(nn)
    medianVar = zeros(numel(bandVar), 1);
    for i = 1:numel(bandVar)
        
        d = get_distance(sens, i);
        
        [~, sortIdx] = sort(d, 'ascend');
        medianVar(i) = median(bandVar(sortIdx(1:min(nn, numel(d)))));
        
    end
    medianVar(medianVar < 1e-3) = median(medianVar);    
end

% Normalize based on local variance

if ~isempty(nn) && ~isinf(nn),
    bandVar = bandVar./medianVar;
end

if logScale,
    rankVal = 10*log10(bandVar);
else
    rankVal = bandVar;
end


end


function bandVar = nonzero_noninf(bandVar)

isZero = (bandVar < eps);

if all(isZero),
    error('bad_channels:ZeroVariance', ...
        'All data channels have zero-variance!');
end

bandVar(isZero) = 1e-3*min(bandVar(~isZero));

isInf = (bandVar > 1e1000);

isInf(bandVar(isInf) < 1000*max(bandVar(~isInf))) = false;

if all(isInf),
    error('bad_channels:InfVariance', ...
        'All data channels have infinite variance!');
end

bandVar(isInf) = 1e3*max(bandVar(~isInf));


end
