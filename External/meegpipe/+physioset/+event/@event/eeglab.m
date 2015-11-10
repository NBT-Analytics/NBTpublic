function [ev, epochDur, trialBeginEv] = eeglab(a, makeEpochs)
% EEGLAB - Conversion to EEGLAB events
%
% sArray = eeglab(eArray);
% [sArray, epochDur] = eeglab(eeglab);
%
% Where
%
% EARRAY is an array of event objects
%
% SARRAY is a struct array according to EEGLAB's format. This array should
% be placed in the field 'event' of a given EEGLAB EEG data structure.
%
% EPOCHDUR is the duration of the data epochs, if ERRAY contains
% trial_begin events. If there are no such events, then EPOCHDUR is set to
% NaN.
%
% See also: from_eeglab, struct, fieldtrip

if nargin < 2 || isempty(makeEpochs), makeEpochs = true; end

%% Discontinuity events are special.
% In meegpipe a single discontinuity event encodes a bad epoch (using the
% onset and duration of the discontinuity event). In EEGLAB, this
% translates into two boundary events
mySel = physioset.event.class_selector('Class', 'discontinuity');
[evDisc, evIdx] = select(mySel, a);
if ~isempty(evIdx),
    a(evIdx) = [];
    newEv = [];
    % Replace them with pairs of boundary events
    for i = 1:numel(evIdx)
        pos = get_sample(evDisc(i));
        % A peculiarity of discontinuity events: The duration of the
        % missing data is placed in the Value property (not in Duration).
        % The reason is that otherwise disc events would be removed when
        % converting data to EEGLAB with a reject bad data policy.
        dur = get(evDisc(i), 'Value');
        newEv = [newEv; physioset.event.new(pos, 'Type', 'boundary')]; %#ok<*AGROW>
        if dur > 1,
            % One sample after the bad epoch ends so that the event is not
            % removed when rejecting the bad data after conversion to
            % EEGLAB
            newEv = [newEv; ...
                physioset.event.new(pos+dur, 'Type', 'boundary')];
        end
    end
    a = [a(:);newEv];
    a = sort(a);
end


%% Create trials if necessary
epochDur = NaN;

if makeEpochs,
    isTrialBegin = arrayfun(@(x) isa(x, 'trial_begin'), a);
    trialBeginEv = a(isTrialBegin);
end

if makeEpochs && ~isempty(trialBeginEv),
    
    trialBegin = get(trialBeginEv, 'Sample');
    
    epochDur = unique(trialBeginEv, 'Duration');
    
    if numel(epochDur) > 1,
        ME = MException('event:DiffDurEpochs', ...
            'EEGLAB format cannot handled different duration epochs');
        throw(ME);
    end
    
    trialEnd = trialBegin + epochDur - 1;
    
    if trialBegin(1) ~= 1,
        ME = MException('event:WrongTrialBegin', ...
            'EEGLAB epochs should start at sample 1');
        throw(ME);
    end
    
    a(isTrialBegin) = [];
    
    if isempty(a),
        pos = [];
    else
        pos = get(a, 'Sample');
    end
    
    if iscell(pos), pos = cell2mat(pos); end
    
    epochVal = nan(size(pos));
    
    for i = 1:numel(pos),
        
        tmp = find(pos(i) >= trialBegin & pos(i) <= trialEnd, 1, 'first');
        
        if (pos(i) + epochDur - 1) > trialEnd
            a(i) = set(a(i), 'Duration', trialEnd-pos(i)+1);
        end
        
        if isempty(tmp),
            warning('event:OutOfRange', ...
                ['Event %d at sample %d seems to be out of range. '...
                'I will remove it.'], i, pos(i));
        else
            epochVal(i) = tmp;
        end
        
    end
    
    epoched = true;
    
else
    
    epoched = false;
    epochVal = [];
    
end

if ~isempty(epochVal),
    outOfRange = isnan(epochVal);
    if epoched,
        % Remove events that do not fall within any epoch
        a(outOfRange)        = [];
        epochVal(outOfRange) = [];
    end
end

args = {'type', '', 'latency', [], 'position', [], 'urevent', [], ...
    'meta', struct};

if epoched,
    args = [args, {'epoch', []}];
end

if isempty(a),
    ev = [];
    return;
end

evStr = struct(args{:});

ev    = repmat(evStr, 1, numel(a));

% These are meta-props that have a meaning in EEGLAB
eeglabFields  = {'Position', 'Epoch', 'Urevent'};

types = get(a, 'Type');
if ischar(types), types = {types}; end

sample = get(a, 'Sample');

for i = 1:numel(a)
    
    ev(i).type     = types{i};
    ev(i).latency  = sample(i);
    ev(i).position = get_meta(a(i), 'Position');
    ev(i).urevent  = get_meta(a(i), 'Urevent');
    
    if epoched
        ev(i).epoch = epochVal(i);
    end
    
    metaData      = get_meta(a(i));
    
    duplicateFields = intersect(fieldnames(metaData), eeglabFields);
    ev(i).meta      = rmfield(metaData, duplicateFields);
    
end


end