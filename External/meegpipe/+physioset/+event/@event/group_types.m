function obj = group_types(obj)
% GROUP_TYPES - Attempts to group event labels in fewer groups
%
% evArrayOut = group_types(evArray) 
%
% 
% Where
%
% EVARRAY is an array of pset.event objects
%
% EVARRAYOUT is a processed array of pset.event objects in which events of
% indexed types have been group as a single event type. This is done by
% looking for event types that include a serial number, e.g. 'TR pulse 1' 
% and 'TR pulse 2' would be grouped under type 'TR pulse'. This method is 
% useful for grouping repetitive events (e.g. TR pulses) under the same
% event type. 
%
%
%
% See also: pset.event

% Documentation: class_pset_event.txt
% Description: Groups indexed events

import misc.strtrim;

if numel(obj) < 1, return; end

n_ev = numel(obj);
types = repmat({''}, n_ev, 1);

for i = 1:n_ev
    if ischar(obj(i).Type),
        types{i} = strtrim(remove_numbers(obj(i).Type));
    end
end

[B,~,J] = unique(types);

if length(B) < length(types),
    for i = 1:length(B)
        idx = find(J==i);
        for j = 1:length(idx)
            obj(idx(j)).Type = B{i};
        end
    end
end


end


function str = remove_numbers(str)

l_str = length(str);
isnumber = false(1,l_str);
for j = 1:l_str
    if ~ismember(str(j), {'i', 'j'}) && ...
            ~isnan(str2double(str(j))),
        isnumber(j) = true;
    end
end
if ~all(isnumber),
    str(isnumber) = [];
end

end