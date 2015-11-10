function count = fprintf(fid, obj, varargin)

sArray = sensor_groups(obj);

count = 0;
for i = 1:numel(sArray),
    sensGroupName = regexprep(class(sArray{i}), '.+\.([^.]+)$', '$1');
    fprintf(fid, '__Sensor group %d: %s__\n\n', i, upper(sensGroupName));
    count = count + fprintf(fid, sArray{i}, varargin{:});
end


end