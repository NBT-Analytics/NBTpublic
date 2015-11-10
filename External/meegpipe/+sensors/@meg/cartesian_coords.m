function xyz = cartesian_coords(obj)

xyz = obj.Cartesian;

if isempty(xyz),
    xyz = nan(nb_sensors(obj), 3);
end

end