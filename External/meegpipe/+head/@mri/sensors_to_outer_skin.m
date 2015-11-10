function obj = sensors_to_outer_skin(obj)

obj.Sensors = map2surf(obj.Sensors, obj.OuterSkin);

end