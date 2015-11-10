function [evArray, rawIdx] = get_event(obj, idx)
% GET_EVENT - Get event(s) from physioset object
%
% evArray = get_event(obj, idx)
% [evArray, rawIdx] = get_event(obj, idx)
%
% Where
%
% IDX is an array with the indices of the events to be retrieved. If not
% provided or empty, get_event() will return all events contained within
% the provided physioset object OBJ.
%
% RAWIDX is an array of indices specifying the raw physioset events that
% were actually returned. Recall that raw events may differ from the
% "effective" events of a dataset in the presence of data selections.
%
% See also: nb_event, physioset, pset.event


import exceptions.*

if nargin < 2 || isempty(idx), idx = []; end

if ~isempty(idx) && nb_event(obj) < 1,
    throw(InvalidArgValue('IDX', ...
        'The provided physioset object does not contain any event'));
end

if ~isempty(idx) && any(idx < 1 | idx > nb_event(obj)),
    throw(InvalidArgValue('IDX', ...
        sprintf('Must be an integer in the range [1 %d]', nb_event(obj))));
end

pntSel = pnt_selection(obj);

if isempty(pntSel),
    
    evArray = obj.Event;
    rawIdx  = 1:numel(evArray);
    
else
    
    if numel(pntSel) == obj.NbPoints,
        evArray = obj.Event;
        rawIdx = 1:numel(obj.Event);
    else
        evSel = physioset.event.sample_selector(pntSel);
        [evArray, rawIdx] = select(evSel, obj.Event);
        
        if isempty(evArray), return; end
        
        % And now re-map the Sample property to match selection
        origSample = get_sample(evArray);
        
        % Something smarter would be nice...
        newSample = nan(size(origSample));
        for i = 1:numel(origSample)
            
            newSample(i) = find(pntSel == origSample(i), 1, 'first');
            
        end
        
        evArray = set_sample(evArray, newSample);
    end
    if isempty(evArray), return; end
  
end

if ~isempty(idx),
    evArray = evArray(idx);
    rawIdx  = rawIdx(idx);
end


end