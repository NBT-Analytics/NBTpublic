function [featVal, featName] = extract_feature(obj, ~, tSeries, raw, varargin)

import misc.peakdet;
import misc.eta;
import goo.pkgisa;

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
    fprintf([verboseLabel 'Computing PSD peak features ...']);
end

featVal = zeros(3, size(tSeries,1));
featName = {'Peakyness', 'Width', 'PeakFreq'};

for sigIter = 1:size(tSeries, 1)
    % Normalized PSD
    pf  = hpsd{sigIter};
    pf  = pf./sum(pf);

    % Find the largest peak within the target band(s)
    peakVal = -Inf;
    peakPos = [];
    for bandItr = 1:size(obj.TargetBand, 1)
        f0  = obj.TargetBand(bandItr, 1);
        f1  = obj.TargetBand(bandItr, 2);
        isInBand        = freqs>= f0 & freqs<=f1;
        pf(~isInBand) = -Inf;
        [thisPeakVal, thisPeakPos] = max(pf);
        if thisPeakVal > peakVal,
            peakVal = thisPeakVal;
            peakPos = thisPeakPos;
        end
    end

    % Calculate the 3dB bandwidth

    afterPeak = freqs > freqs(peakPos);

    if ~any(afterPeak),
        peakWidth = NaN;
    else
        idx = find(pf(afterPeak) < peakVal/2, 1, 'first');
        if isempty(idx),
            peakWidth = NaN;
        else
            peakWidth = freqs(peakPos+idx)-freqs(peakPos);
        end
    end
    beforePeak = freqs < freqs(peakPos);
    if ~any(beforePeak),
        peakWidth = NaN;
    else
        idx = find(pf(beforePeak) < peakVal/2, 1, 'last');
        if isempty(idx),
            peakWidth = NaN;
        else
            beforePeakWidth = freqs(peakPos) - freqs(idx);
            if beforePeakWidth > peakWidth,
                peakWidth = beforePeakWidth;
            end
        end
    end

    if isnan(peakWidth),
        peakyness = NaN;
    else
        peakyness = peakVal/peakWidth;
    end

    featVal(:, sigIter) = [peakyness;peakWidth;freqs(peakPos)];

    if verbose,
        eta(tinit, size(tSeries, 1), sigIter, 'remaintime', false);
    end
end

if verbose, fprintf('\n\n'); end

idx = find(ismember(featName, obj.MainFeature));
permOrder = [idx setdiff(1:numel(featName), idx)];
featName = featName(permOrder);
featVal  = featVal(permOrder, :);


end