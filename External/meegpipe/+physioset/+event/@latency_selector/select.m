function [evArray, idx] = select(obj, evArray)
% SELECT - Selects events within a latency range
%
% evArrayOut = select(obj, evArray)
%
% Where
%
% EVARRAY is an (array of) event objects.
%
% EVARRAYOUT is a new array of event objects that contains only those
% events in EVARRAY within the relevant latency range. If property
% ResetStartLatency is set to true, the latencies (and derived properties)
% of the output events will be shifted backwards by LatencyRange(1)
% seconds.
%
% See also: latency, selector


if nargin < 2 || isempty(evArray),
    
    evArray = [];
    return;
    
end


sampleRange = obj.LatencyRange*obj.SamplingRate;
selected    = false(size(evArray));

for i = 1:size(obj.LatencyRange,1)
       
    range = sampleRange(i,:);
    af = @(x) x.Sample >= range(1) && x.Sample <= range(2);
    selected = selected | arrayfun(af, evArray);
    
end

if obj.Negated,
    selected = ~selected;
end

evArray = evArray(selected);

idx = find(selected);


end