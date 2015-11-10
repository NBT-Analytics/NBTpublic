function obj = from_tal(talArray)
% FROM_TAL - Constructs event array from a cell array of TALs
%
% evArray = from_tal(talArray)
%
% Where
%
% TALARRAY is a cell array of Time Annotated Lists (TALs), such as those
% used in the EDF+ standard.
%
% EVARRAY is an equivalent array of pset.event objects.
%
%
% See also: physioset.event.from_struct, pset.event

% Description: Construction from a cell array of TALs
% Documentation: class_pset_event.txt

import physioset.event.event;

obj     = repmat(event, numel(talArray), 1);
sample  = nan(numel(talArray), 1);
evCount = 0;
for i = 1:numel(talArray)
    for j = 1:length(talArray{i})
        if ~isempty(talArray{i}(j).annotations)
            for k = 1:length(talArray{i}(j).annotations)
                if isnan(talArray{i}(j).onset_samples), continue; end
                evCount = evCount + 1;
                
                obj(evCount).Type     = talArray{i}(j).annotations{k};
                obj(evCount).Sample   = talArray{i}(j).onset_samples;
                sample(evCount)       = talArray{i}(j).onset_samples;
                obj(evCount).Time     = talArray{i}(j).onset;
                obj(evCount).Duration = talArray{i}(j).duration_samples;
                obj(evCount).TimeSpan = talArray{i}(j).duration;
            end
            
        end
    end
end
if evCount < 1,
    obj = [];
else
    obj(evCount+1:end)=[];
end



end