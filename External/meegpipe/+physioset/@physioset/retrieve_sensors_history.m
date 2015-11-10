function sensObj = retrieve_sensors_history(obj, idx)


if nargin < 2 || isempty(idx),
    idx = 1;
end

if numel(obj.SensorsHistory) < idx,
    sensObj = [];
else
    sensObj = obj.SensorsHistory{idx};
end


end