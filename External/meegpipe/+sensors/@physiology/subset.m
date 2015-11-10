function obj = subset(obj, idx)
% SUBSET - Creates a sensors.physiology object as a subset of another
%
% objSubset = subset(obj, idx)
%
% Where
%
% OBJSUBSET object is a sensors.physiology object that contains the sensors.
% with indices IDX in object OBJ
%
% See also: sensors.physiology

if islogical(idx),
    idx = find(idx);
end

if isempty(idx),
    obj = sensors.physiology;
    return;
end

if ~isempty(obj.TransducerType),
    obj.TransducerType = obj.TransducerType(idx);
end

if ~isempty(obj.Label),
    obj.Label = obj.Label(idx);
end

if ~isempty(obj.OrigLabel),
    obj.OrigLabel = obj.OrigLabel(idx);
end

if ~isempty(obj.PhysDim),
    obj.PhysDim = obj.PhysDim(idx);
end

end