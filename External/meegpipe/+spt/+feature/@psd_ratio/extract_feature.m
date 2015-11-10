function [featVal, featName] = extract_feature(obj, ~, tSeries, raw, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;

featName = [];

if nargin < 4 || isempty(raw),
    sr = tSeries.SamplingRate;
else
    sr = raw.SamplingRate;
end

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

hpsd  = cell(size(tSeries, 1), 1);
tinit = tic;
if verbose,
    fprintf([verboseLabel 'Computing PSDs ...']);
end

for sigIter = 1:size(tSeries,1)
    [hpsd{sigIter}, freqs] = obj.Estimator(tSeries(sigIter,:), sr);
    if verbose,
        eta(tinit, size(tSeries, 1), sigIter, 'remaintime', false);
    end
end

if verbose, fprintf('\n\n'); end

if verbose,
    fprintf([verboseLabel 'Computing spectral ratios...']);
end

featVal = zeros(1, size(tSeries,1));

for sigIter = 1:size(tSeries, 1)
    % Normalized PSD  
    pf  = hpsd{sigIter};
    pf  = pf./sum(pf);
    
    % Calculate power in band of interest
    narrowBandPower = [];
    for bandItr = 1:size(obj.TargetBand, 1)
        f0  = obj.TargetBand(bandItr, 1);
        f1  = obj.TargetBand(bandItr, 2);
        isInBand        = freqs>= f0 & freqs<=f1;      
        narrowBandPower = [narrowBandPower;pf(isInBand)]; %#ok<AGROW>
    end
    narrowBandPower = obj.TargetBandStat(narrowBandPower);
    
    % Calculate power in the "other" band
    otherPower = [];
    for bandItr = 1:size(obj.RefBand, 1)
        f02  = obj.RefBand(bandItr, 1);
        f12  = obj.RefBand(bandItr, 2);
        isOtherBand = freqs>= f02 & freqs<=f12;    
        otherPower  = [otherPower; pf(isOtherBand)]; %#ok<AGROW>
    end
    otherPower = obj.RefBandStat(otherPower);
    
    featVal(sigIter) = narrowBandPower/otherPower;
    
    if verbose,
        eta(tinit, size(tSeries, 1), sigIter, 'remaintime', false);
    end   
end

if verbose, fprintf('\n\n'); end

end