function [y, evNew, samplIdx, evOrig, trialEv] = epoch_get(x, trialEv, base)
% EPOCH_GET - Get data epochs from physioset
%
% [y, evNew, samplIdx, evOrig, trialEv] = epoch_get(x, trialEv, base)
%
% Where
%
% X is a physioset object
%
% TRIALEV is an array of event objects. These events will be used to
% produce the data epochs.
%
% BASE is a boolean value. If BASE is true, the epochs will be baseline
% corrected. 
%
% Y is a NxMxK data matrix with K N-dimensional data epochs. 
%
% EVNEW is the result of mapping the events in X to the time frame of Y.
%
% SAMPLIDX is a numeric array with the indices of the data samples of X
% that correspond to the data epochs in Y.
%
% EVORIG is a 1xK array of events having the same time frame as the input
% physioset. EVORIG is the subset of events from X that fall within any of
% the epochs in Y.
%
% TRIALEV is an array of event objects. It is the subset of the input
% TRIALEV that was actually used to produce Y. That is, numel(TRIALEV) is 
% always equal to size(Y, 3).
%
% See also: physioset

import physioset.event.std.trial_begin;

if nargin < 3 || isempty(base), base = false; end

if isempty(trialEv),
    y           = [];
    evNew       = [];
    samplIdx    = [];
    evOrig      = [];
    trialEv     = [];
    return;
end

dur = unique(get_duration(trialEv));

off = get_offset(trialEv);

if numel(dur) > 1,
    error('epoch_get:DifferentLengthTrials', ...
        'Trials of multiple lenghts are not supported');
end

% Reject trials that are out of range
pos = get_sample(trialEv);

outOfRange = (pos + off) < 1 | (pos + off + dur -1) > size(x,2);
    
trialEv(outOfRange) = [];
pos(outOfRange)     = [];
off(outOfRange)     = [];

if isempty(trialEv),
    y = [];
    evNew = [];
    samplIdx = [];
    evOrig = [];
    return;
end

% Indices of the picked samples
pos = reshape(pos, numel(pos), 1);
off = reshape(off, numel(off), 1);
idx = repmat(pos+off, 1, dur) + repmat(0:dur-1, numel(pos), 1);
idx = idx';
y   = reshape(x.PointSet(:, idx(:)), [size(x, 1), dur, numel(pos)]);

% Baseline correction
if base,
   baseValue = zeros(numel(pos), 1);
   for i = 1:numel(pos)
      if off(i) >= 0, continue; end
      baseValue(:, i) = mean(squeeze(y(:, 1:abs(off(i)), i)), 2); 
      y(:, :, i) = y(:,:,i) - repmat(baseValue, [1 dur 1]);
   end
    
end

% Reject physioset events that do not fall in any trial
ev = get_event(x);

if isempty(ev), 
    evNew    = [];
    evOrig   = [];
    samplIdx = idx;
    return;    
end

pos = get_sample(ev);
dur = get_duration(ev);
off = get_offset(ev);
reject = false(1, numel(ev));
for i = 1:numel(ev)
   
    thisIdx = (pos(i)+off(i)):(pos(i)+off(i)+dur(i)-1);
    reject(i) = ~all(ismember(thisIdx(:)', idx(:)'));
    
end
ev(reject) = [];

if isempty(ev),
    evNew       = [];
    samplIdx    = idx;
    evOrig      = [];
    return;
end


% Mapping between original and new time frame of physioset events
[~, orig2new] = ismember(get_sample(ev), idx);
evNew = set_sample(ev, orig2new);
evOrig = ev;
samplIdx = idx;


end