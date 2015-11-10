function [data, dataNew] = process(obj, data, varargin)

import misc.eta;

dataNew =[];

verboseLabel = get_verbose_label(obj);
verbose      = is_verbose(obj);

% Configuration options
LPF      = get_config(obj, 'LPF');  %#ok<*NASGU>
L        = get_config(obj, 'L');
Window   = get_config(obj, 'Window');
trDur    = get_config(obj, 'TR');
nbSlices = get_config(obj, 'NbSlices');
ANC      = get_config(obj, 'ANC');
OBS      = get_config(obj, 'OBS');

% Locations of the TR events
if verbose,
    fprintf([verboseLabel 'Selecting TR events...']);
end
evSel    = get_config(obj, 'EventSelector');
trEvents = select(evSel, get_event(data));
if verbose,
    fprintf('[%d selected]\n\n', numel(trEvents));
end

if isempty(trEvents),
    error('obs:NoTREvents', ...
        'I found no TR events: MR correction cannot be performed');
end

tr  = get_sample(trEvents);

trDurSampl = round(trDur*data.SamplingRate);
if median(diff(tr)) ~= trDurSampl,
    error(['The timing of the TR events is not consistent with ' ...
        'TR=%1.3f secs'], trDur);
end

% Boundaries between slices
slice = round(linspace(0, trDurSampl, nbSlices+1));%trDurSampl-1
slice = slice(2:end);

if tr(1) < max(slice),
    extra = fliplr(tr(1) - slice);
    extra(extra<1) = [];
    tr = tr(2:end);
else
    extra = [];
end

% Starting points of all slices
sliceBegin = repmat(tr, 1, numel(slice)) - repmat(slice, numel(tr), 1);
sliceBegin = fliplr(sliceBegin)';
sliceBegin = [extra(:);sliceBegin(:)]; 
if verbose,
    fprintf([verboseLabel 'Running FMRIB''s EEGLAB plug-in...']);
end

% Convert data to EEGLAB format but only channel by channel
% This is not perfect, but better than converting all data at once
tinit = tic;
for i = 1:size(data,1)
    select(data, i);
    EEG  = eeglab(data);
    EEG.data = double(EEG.data);
    EEG.data(isnan(EEG.data) | isinf(EEG.data)) = 0;
    try
    evalc(['EEG = fmrib_fastr(EEG, LPF, L, Window, sliceBegin, 1, '  ...
        'ANC, 0, 0, 0, 0)']);
    catch ME
        if strcmp(ME.identifier, 'MATLAB:svd:matrixWithNaNInf'),
            warning('mra_fmrib:InternalFMRIBError', ...
                'Internal FMRIB error: channel %d will be discarded', i);
            EEG.data = zeros(size(EEG.data));
        else
            rethrow(ME);
        end
    end
    data(1,:) = EEG.data;
    restore_selection(data);   
    if verbose,
        eta(tinit, size(data,1), i, 'RemainTime', true);
    end
end


if verbose, fprintf('\n\n'); end



end