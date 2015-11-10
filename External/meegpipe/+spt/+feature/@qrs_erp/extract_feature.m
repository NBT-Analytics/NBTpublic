function [featVal, featName] = extract_feature(obj, ~, tSeries, data, varargin)

featName = [];

epochDuration = obj.EpochDuration; % In seconds
nbEpochs      = obj.NbEpochs;

verbose       = is_verbose(obj);
verboseLabel  = get_verbose_label(obj);

if nargin < 4 || isempty(data),
    sr = tSeries.SamplingRate;
else
    sr = data.SamplingRate;
end

if ~isempty(obj.Filter)
    if verbose,
        fprintf([verboseLabel ...
            'Pre-filtering before extracting qrs_erp features ...\n\n']);
    end
    if isa(tSeries, 'pset.mmappset'),
        tSeries = copy(tSeries);
    end
    
    if isa(obj.Filter, 'function_handle'),
        filtObj = obj.Filter(sr);
    else
        filtObj = obj.Filter;
    end
    
    tSeries = filter(filtObj, tSeries);
end

if verbose,
    fprintf([verboseLabel 'Extracting qrs_erp features ...']);
end

% Onset of the nbEpochs sample windows that will be used as a representative
% sample of the whole dataset. Important: Do not pick windows randomly as
% that would prevent reproducing any results that use qrs_erp features.
winDur = sr*epochDuration;
init = 1:winDur:size(tSeries,2)-winDur;
if isempty(init), init = 1; end
idx  = round(linspace(1, numel(init), nbEpochs + 1));
idx  = unique(idx);
init = init(idx);

off = -floor(obj.Offset*sr);
dur = floor(obj.Duration*sr);

[featVal, allPeakLocs] = compute_feat_val(tSeries, init, winDur, sr, ...
    obj.EpochAggregationStat, obj.CorrAggregationStat, off, dur, verbose);

%% Post-processing
% If the first-ranked component has a high rank then use the peak locations
% that are extracted from the top component
[maxVal, maxIdx] = max(featVal);

if maxVal > 0.5,
   if verbose,
      fprintf([verboseLabel ...
          'Recomputing with R-peak locations from top-ranked component ...']);
   end
   peakLocs = allPeakLocs(maxIdx, :);
   featVal = compute_feat_val(tSeries, init, winDur, sr, ...
       obj.EpochAggregationStat, obj.CorrAggregationStat, off, dur, verbose, peakLocs);
   if verbose,
       clear +misc/eta;
       fprintf('\n\n');
   end
end

end


% Helper functions #############################################################

function [featVal, allPeakLocs] = compute_feat_val(tSeries, init, winDur, ...
    sr, epochAggrStat, corrAggrStat, off, dur, verbose, providedPeakLocs)

import misc.eta;
import fmrib.my_fmrib_qrsdetect;
import misc.epoch_get;

if nargin < 10,
    providedPeakLocs = [];
end

if verbose, tinit = tic; end
featVal = zeros(1, size(tSeries,1));
allPeakLocs = cell(size(tSeries, 1), numel(init));

for j = 1:size(tSeries,1)
    
    winStatVal = nan(1, numel(init));
    for i = 1:numel(init)
        winData = tSeries(j, init(i):min(init(i)+winDur, size(tSeries,2)));
        if isempty(providedPeakLocs),
            evalc('peakLocs = my_fmrib_qrsdetect(winData, sr, false)');
        else
            peakLocs = providedPeakLocs{i};
        end
        allPeakLocs{j, i} = peakLocs;
        if numel(peakLocs) < (winDur/sr)/2 || numel(peakLocs) > (winDur/sr)*2,
            winStatVal(i) = 0;
            continue;
        end        
  
        erp   = epoch_get(winData, peakLocs, ...
            'Duration', dur, ...
            'Offset',   off);
        corrVal = get_qrs_corrval(erp);
        winStatVal(i) = corrAggrStat(corrVal); 
        
        % Penalize windows where the median RR is too large or too small
        medRR = median(diff(peakLocs))/sr;
        if medRR > 1.1,  % 55 bpm
            winStatVal(i) = (1-min((medRR-1.1), 1))*winStatVal(i);
        end
        if medRR < 0.47, % 128 bpm
            winStatVal(i) = (1-min((0.47-medRR)*2, 1))*winStatVal(i);
        end
        
    end
    if verbose,
        eta(tinit, size(tSeries,1), j, 'remaintime', false);
    end
    featVal(j) = epochAggrStat(winStatVal);
end
if verbose, 
    clear +misc/eta;
    fprintf('\n\n'); 
end

end

function corrVal = get_qrs_corrval(erp)

% Normalize epochs to have zero mean and unit variance
erp   = squeeze(erp);
erp   = erp - repmat(mean(erp), size(erp,1), 1);
erp   = erp./repmat(sqrt(var(erp)), size(erp, 1), 1);

% Compute xcorr between ERP and individual trials
erpAvg  = mean(erp, 2);
erpAvg  = erpAvg - mean(erpAvg);
erpAvg  = erpAvg./sqrt(var(erpAvg));
corrVal = erpAvg'*squeeze(erp)/numel(erpAvg);
corrVal = abs(corrVal);

end