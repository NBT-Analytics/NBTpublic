function obj = set_physdim(obj, value)

[grps, grpIdx] = sensor_groups(obj);

for i = 1:numel(grps)
   thisSensors = grps{i};
   thisSensors = set_physdim(thisSensors, value(grpIdx{i}));
   obj.Sensors{i} = thisSensors;
end

end