function obj = subset(obj, idx)

if ~isempty(obj.Cartesian),
    obj.Cartesian   = obj.Cartesian(idx,:);
end
obj.Weights     = obj.Weights(idx,:);


end