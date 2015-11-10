function obj = subset(obj, idx)

if islogical(idx), idx = find(idx); end

if isempty(idx),
    obj = sensors.meg;
    return;
end

obj = subset@sensors.physiology(obj, idx);

if ~isempty(obj.Cartesian),
    obj.Cartesian   = obj.Cartesian(idx,:);
end

if ~isempty(obj.Orientation),
    obj.Orientation = obj.Orientation(idx,:);
end

if ~isempty(obj.Coils)
    obj.Coils = subset(obj.Coils, idx);
end

end