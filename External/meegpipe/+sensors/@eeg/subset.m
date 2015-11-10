function obj = subset(obj, idx)

if islogical(idx), idx = find(idx); end

if isempty(idx),
    obj = sensors.eeg;
    return;
end

obj = subset@sensors.physiology(obj, idx);

if ~isempty(obj.Cartesian),
    obj.Cartesian = obj.Cartesian(idx,:);
end


end