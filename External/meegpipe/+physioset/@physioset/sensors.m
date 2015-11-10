function sensObj = sensors(obj)

if ~isempty(obj.DimSelection),
    sensObj = subset(obj.Sensors, obj.DimSelection);
else
    sensObj = obj.Sensors;
end


end