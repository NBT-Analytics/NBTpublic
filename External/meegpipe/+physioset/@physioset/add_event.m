function [obj, idx] = add_event(obj, evArray)
% ADD_EVENT - Adds events to a physioset
%
% obj = add_event(obj, evArray)
%
% Where
%
% EVARRAY is an array of pset.event objects
%
% See also: event, physioset

if nargin < 2,
    add_event_gui(obj);
    idx = [];
    return;
end

if isempty(evArray), 
    idx = [];
    return; 
end

% When there are selections, we need to remap the events Sample property
pntSel = pnt_selection(obj);
if ~isempty(pntSel),
   
    origSample = cell2mat(get_sample(evArray));  
    
    % This happens sometimes and we don't want to produce an error for such
    % a tiny inconsistency. 
    origSample(origSample(end) == numel(pntSel) + 1) = numel(pntSel);
    
    if any(origSample > numel(pntSel)),      
        error('Out of range event');
    end
    
    newSample  = pntSel(origSample);
    evArray    = set_sample(evArray, newSample);
    
end

if isempty(obj.Event),
    idx = 1:numel(evArray);
else
    nbEvs = numel(evArray);
    evArray = [obj.Event(:); evArray(:)];
    idx = numel(obj.Event)+1:numel(obj.Event)+nbEvs;
end

[evArray, reIdx] = sort(evArray);

obj.Event = evArray;

newIdx = false(1, numel(evArray));
newIdx(idx) = true;
idx = find(newIdx(reIdx));

end