function obj = subset(obj, idx)

if islogical(idx),
    idx = find(idx);
end

if isempty(idx),
    obj = [];
    return;
end

sortedIdx = sort(idx);

if any(sortedIdx ~= idx),
   error('Indices must be sorted'); 
end

[~, groupIdx] = sensor_groups(obj);

sensorClass = mjava.hash;
for i = 1:numel(groupIdx)
   sensorClass{groupIdx{i}} = i; 
end

notValid = ~ismember(idx, cell2mat(keys(sensorClass)));

if any(notValid),
    idx = regexprep(num2str(idx(notValid)), '\s+', ', ');
    error('Some sensors.indices are not valid: %s', idx);
end

allClasses = sensorClass(idx);
if iscell(allClasses),
    allClasses = cell2mat(allClasses);
end

sensorCount = 0;
groupCount = 0;
sensorGroups = cell(1, numel(groupIdx));
for i = 1:numel(groupIdx)   
   thisIdx = idx(allClasses == i);
   if ~isempty(thisIdx),
       groupCount = groupCount + 1;
       thisIdx = thisIdx - sensorCount;
       sensorGroups{groupCount} =  subset(obj.Sensor{i}, thisIdx);       
   end
   sensorCount = sensorCount + numel(groupIdx{i});
end
sensorGroups(groupCount+1:end) = [];
if groupCount == 1,
    obj = sensorGroups{1};
else
    obj = sensors.mixed(sensorGroups{:});
end
    




end