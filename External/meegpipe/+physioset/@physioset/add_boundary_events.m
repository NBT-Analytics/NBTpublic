function [obj, evIdx] = add_boundary_events(obj, evClass)

if nargin < 2 || isempty(evClass), evClass = 'discontinuity'; end

winrej = eeglab_winrej(obj);

evIdx = nan(1, size(winrej,1));
count = 0;

% Get already existing events (to avoid adding duplicates)
ev = get_event(obj);
existingEvSampl = [];
mySel = physioset.event.class_selector('Class', evClass);
if ~isempty(ev),
    ev = select(mySel, ev);
    if ~isempty(ev),
        existingEvSampl = get_sample(ev);
    end
end

for i = 1:size(winrej,1)
    pos = winrej(i,1);
    if pos < 1, continue; end
    dur = diff(winrej(i,1:2))+1;
    if pos > 1,
        pos = pos - 1;
        dur = dur + 1;
    end
    if ismember(pos, existingEvSampl), continue; end
    
    samplTime = get_sampling_time(obj);
    
    lat = samplTime(pos);
    
    if strcmp(evClass, 'discontinuity'),
        % Otherwise, disconuity events will be gone when dealing with bad
        % data when converting to EEGLAB or Fieldtrip
        value = dur;
        dur = 1;
    else
        value = [];
    end
    thisEv = feval(['physioset.event.std.' evClass], pos, 'Time', lat, ...
        'Duration', dur, 'Value', value);
    [~, evIdx(i)] = add_event(obj, thisEv);
    count = count + 1;
end
evIdx(count+1:end) = [];

end